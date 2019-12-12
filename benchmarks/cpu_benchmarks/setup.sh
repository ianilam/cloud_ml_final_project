#!/bin/bash
function system_setup() {
    sudo apt-get -y update
    sudo apt-get -y install sysbench expect bonnie++ python3 python3-pip

    wget http://www.numberworld.org/y-cruncher/y-cruncher%20v0.7.8.9503-static.tar.xz
    tar -xvf "y-cruncher v0.7.8.9503-static.tar.xz"
    rm -rf "y-cruncher v0.7.8.9503-static.tar.xz"
    mv "y-cruncher v0.7.8.9503-static" y-cruncher

    chmod +x *.sh

    pip3 install torch==1.3.1+cpu torchvision==0.4.2+cpu -f https://download.pytorch.org/whl/torch_stable.html --no-cache-dir
}

function system_sysbench() {
    ./sysbench_tests.sh
    rm -rf test_file*
}

function system_ycruncher() {
    ./run_y-cruncher.sh .
    rm -rf Pi* y-cruncher*
}

function system_dd() {
    time sh -c "dd if=/dev/zero of=./test_write.tmp bs=4k count=1000000 && sync"
    rm -f ./test_write.tmp

    dd if=/dev/zero of=./test_read.tmp bs=4k count=251889
    time sh -c "dd if=./test_read.tmp of=/dev/null bs=4k"
    rm -f ./test_read.tmp
}

function system_bonnie() {
    bonnie++ -d /tmp -r 2048 -u ubuntu
}

function system_mnist() {
    mkdir -p logs
    time python3 -m cProfile -o ./logs/cprofile_log_mnist ../mnist-benchmark/mnist/main.py --epochs 1
    rm -rf data
}

function system_imagenet() {
    mkdir -p logs
    time python3 ../imagenet-benchmark/app/main.py -a alexnet -b 8 --epochs 1 --lr 0.01 -j 0 ../imagenet-benchmark/app/ > logs/log_imagenet
}

function system_cleanup() {
    rm -rf logs
    pip3 uninstall -y torch torchvision
    sudo apt-get -y purge sysbench expect bonnie++ python3 python3-pip
    sudo apt-get -y autoremove
    rm -rf y-cruncher*
}




function forcecpchroot() {
    sudo mkdir -p ~/cmlroot$(dirname $2)
    sudo cp -r -v $1 ~/cmlroot$2
}

function forceaddprogramchroot() {
    sudo mkdir -p ~/cmlroot$(dirname $1)
    sudo cp -v $1 ~/cmlroot$1
}

function addprogramchroot() {
    program=$(which $1)
    forceaddprogramchroot $program

    sudo ldd $program | grep '=>' | awk '{ print $3 }' | while read line ;
    do
        forceaddprogramchroot $line
    done

    sudo ldd $program | grep -v '=>' | grep '/' | awk '{ print $program }' | while read line ;
    do
        forceaddprogramchroot $line
    done
}

function chroot_setup() {
    chroot_cleanup
    mkdir ~/cmlroot

    addprogramchroot bash
    addprogramchroot sh
    addprogramchroot ls
    addprogramchroot sysbench
    addprogramchroot expect
    addprogramchroot rm
    addprogramchroot bonnie++
    addprogramchroot dd
    addprogramchroot time
    # addprogramchroot python3
    # addprogramchroot pip3

    sudo chroot ~/cmlroot /usr/bin/sysbench --version

    forcecpchroot ./sysbench_tests.sh /usr/sysbench_tests.sh
    forcecpchroot y-cruncher /usr/
    forcecpchroot ./run_y-cruncher.sh /usr/run_y-cruncher.sh
    forcecpchroot /usr/share/tcltk/tcl8.6/init.tcl /usr/share/tcltk/tcl8.6/init.tcl
    # forcecpchroot ../mnist-benchmark/mnist /usr/mnist

    # sudo mkdir -p ~/cmlroot/usr/mnist/logs

    sudo mkdir -p ~/cmlroot/dev
    sudo mount -v --bind /dev ~/cmlroot/dev
    sudo mkdir -p ~/cmlroot/dev/pts
    sudo mount -vt devpts devpts ~/cmlroot/dev/pts
    sudo mkdir -p ~/cmlroot/dev/shm
    sudo mount -vt tmpfs shm ~/cmlroot/dev/shm
    sudo mkdir -p ~/cmlroot/proc
    sudo mount -vt proc proc ~/cmlroot/proc
    sudo mkdir -p ~/cmlroot/sys
    sudo mount -vt sysfs sysfs ~/cmlroot/sys
}

function chroot_sysbench() {
    sudo chroot ~/cmlroot /usr/sysbench_tests.sh
    sudo chroot ~/cmlroot rm -rf test_file*
}

function chroot_ycruncher() {
    sudo chroot ~/cmlroot /usr/run_y-cruncher.sh /usr
}

function chroot_dd() {
    sudo chroot ~/cmlroot time sh -c "dd if=/dev/zero of=/test_write.tmp bs=4k count=1000000 && sync"
    sudo chroot ~/cmlroot rm -f /test_write.tmp

    sudo chroot ~/cmlroot dd if=/dev/zero of=/test_read.tmp bs=4k count=251889
    sudo chroot ~/cmlroot time sh -c "dd if=/test_read.tmp of=/dev/null bs=4k"
    sudo chroot ~/cmlroot rm -f /test_read.tmp
}

function chroot_bonnie() {
    sudo chroot ~/cmlroot bonnie++ -d /tmp -r 2048 -u ubuntu
}

# function chroot_mnist() {
#     sudo chroot ~/cmlroot pip3 install torch==1.3.1+cpu torchvision==0.4.2+cpu -f https://download.pytorch.org/whl/torch_stable.html --no-cache-dir
#     sudo chroot ~/cmlroot time python3 -m cProfile -o /usr/logs/cprofile_log_mnist ../mnist-benchmark/mnist/main.py --epochs 1
# }

function chroot_cleanup() {
    sudo umount ~/cmlroot/sys
    sudo umount ~/cmlroot/proc
    sudo umount ~/cmlroot/dev/shm
    sudo umount ~/cmlroot/dev/pts
    sudo umount ~/cmlroot/dev
    sudo rm -rf ~/cmlroot
}




function forcecplxc() {
    sudo lxc-attach -n cloudml -- sudo mkdir -p $2
    tar -C $1 -c . | sudo lxc-attach -n cloudml -- /bin/sh -c "tar -C $2 -vx; chmod 1777 $2;"
}

function lxc_setup() {
    lxc_cleanup

    sudo apt-get -y install lxc

    sudo lxc-create -t download -n cloudml -- --dist ubuntu --release bionic --arch amd64

    sudo lxc-start -n cloudml
    sleep 2
    sudo lxc-attach -n cloudml -- apt-get -y update
    
    sudo lxc-attach -n cloudml -- apt -y install sysbench expect bonnie++ time python3 python3-pip

    mkdir -p scripts
    cp *.sh scripts

    forcecplxc ./y-cruncher /home/ubuntu/y-cruncher/
    forcecplxc ./scripts /home/ubuntu
    forcecplxc ../mnist-benchmark/mnist /home/ubuntu/mnist

    sudo lxc-attach -n cloudml -- pip3 install torch==1.3.1+cpu torchvision==0.4.2+cpu -f https://download.pytorch.org/whl/torch_stable.html --no-cache-dir

    rm -rf scripts
}

function lxc_sysbench() {
    sudo lxc-attach -n cloudml -- ./sysbench_tests.sh
    # sudo lxc-attach -n cloudml -- rm -rf './test_file*'
}

function lxc_ycruncher() {
    sudo lxc-attach -n cloudml -- ./run_y-cruncher.sh /home/ubuntu
    # sudo lxc-attach -n cloudml -- rm -rf 'Pi*'
}

function lxc_dd() {
    sudo lxc-attach -n cloudml -- time sh -c "dd if=/dev/zero of=./test_write.tmp bs=4k count=1000000 && sync"
    sudo lxc-attach -n cloudml -- rm -f ./test_write.tmp

    sudo lxc-attach -n cloudml -- dd if=/dev/zero of=./test_read.tmp bs=4k count=251889
    sudo lxc-attach -n cloudml -- time sh -c "dd if=./test_read.tmp of=/dev/null bs=4k"
    sudo lxc-attach -n cloudml -- rm -f ./test_read.tmp
}

function lxc_bonnie() {
    sudo lxc-attach -n cloudml -- bonnie++ -d /tmp -r 2048 -u ubuntu
}

function lxc_mnist() {
    sudo lxc-attach -n cloudml -- mkdir -p /home/ubuntu/mnist/logs
    sudo lxc-attach -n cloudml -- time python3 -m cProfile -o /home/ubuntu/mnist/logs/cprofile_log_mnist /home/ubuntu/mnist/main.py --epochs 1
    sudo lxc-attach -n cloudml -- rm -rf data
}

function lxc_cleanup() {
    sudo lxc-stop -n cloudml
    sudo lxc-destroy -n cloudml
    sudo apt-get -y purge lxc
}




function docker_setup() {
    docker_cleanup
    sudo apt-get update
    sudo apt-get -y remove docker docker-engine docker.io
    sudo apt -y install docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
}

function docker_sysbench() {
    sudo docker run --name cloudml_sysbench nisargthakkar/cloudml_sysbench
    sudo docker rm cloudml_sysbench
    sudo docker rmi nisargthakkar/cloudml_sysbench
}

function docker_ycruncher() {
    sudo docker run --name cloudml_ycruncher nisargthakkar/cloudml_ycruncher
    sudo docker kill cloudml_ycruncher
    sudo docker rm cloudml_ycruncher
    sudo docker rmi nisargthakkar/cloudml_ycruncher
}

function docker_dd() {
    sudo docker run --name cloudml_dd nisargthakkar/cloudml_dd
    sudo docker kill cloudml_dd
    sudo docker rm cloudml_dd
    sudo docker rmi nisargthakkar/cloudml_dd
}

function docker_bonnie() {
    sudo docker run --name cloudml_bonnie nisargthakkar/cloudml_bonnie
    sudo docker kill cloudml_bonnie
    sudo docker rm cloudml_bonnie
    sudo docker rmi nisargthakkar/cloudml_bonnie
}

function docker_mnist() {
    sudo docker run --name cloudml_mnist nisargthakkar/cloudml_mnist
    sudo docker kill cloudml_mnist
    sudo docker rm cloudml_mnist
    sudo docker rmi nisargthakkar/cloudml_mnist
}

function docker_cleanup() {
    sudo docker container kill $(sudo docker container ls -aq)
    sudo docker system prune -f

    sudo systemctl disable docker
    sudo systemctl stop docker
    sudo apt-get -y purge docker docker-engine docker.io
    sudo apt-get -y autoremove
}




function rkt_setup() {
    gpg --recv-key 18AD5014C99EF7E3BA5F6CE950BDD3E0FC8A365E
    wget https://github.com/rkt/rkt/releases/download/v1.29.0/rkt_1.29.0-1_amd64.deb
    wget https://github.com/rkt/rkt/releases/download/v1.29.0/rkt_1.29.0-1_amd64.deb.asc
    gpg --verify rkt_1.29.0-1_amd64.deb.asc
    sudo dpkg -i rkt_1.29.0-1_amd64.deb
}

function rkt_sysbench() {
    hash="$(sudo rkt --insecure-options=image fetch docker://nisargthakkar/cloudml_sysbench | tail -n 1)"
    sudo rkt --insecure-options=image run $hash
    sudo rkt rm $hash
}

function rkt_ycruncher() {
    hash="$(sudo rkt --insecure-options=image fetch docker://nisargthakkar/cloudml_ycruncher | tail -n 1)"
    sudo rkt --insecure-options=image run $hash
    sudo rkt rm $hash
}

function rkt_dd() {
    hash="$(sudo rkt --insecure-options=image fetch docker://nisargthakkar/cloudml_dd | tail -n 1)"
    sudo rkt --insecure-options=image run $hash
    sudo rkt rm $hash
}

function rkt_bonnie() {
    hash="$(sudo rkt --insecure-options=image fetch docker://nisargthakkar/cloudml_bonnie | tail -n 1)"
    sudo rkt --insecure-options=image run $hash
    sudo rkt rm $hash
}

function rkt_mnist() {
    hash="$(sudo rkt --insecure-options=image fetch docker://nisargthakkar/cloudml_mnist | tail -n 1)"
    sudo rkt --insecure-options=image run $hash
    sudo rkt rm $hash
}

function rkt_cleanup() {
    sudo rkt rm $(sudo rkt list --no-legend | awk '{print $1 }')
    sudo apt-get -y purge $(dpkg -I rkt_1.29.0-1_amd64.deb | awk -F: '/Package/ {print $2}')
    sudo apt-get -y autoremove
    sudo rm -r rkt_1.29.0-1_amd64.deb
    sudo rm -r rkt_1.29.0-1_amd64.deb.asc
}




system_setup
system_sysbench
system_ycruncher
system_dd
system_bonnie
system_mnist
# system_imagenet

chroot_setup
chroot_sysbench
# chroot_ycruncher
chroot_dd
chroot_bonnie
# chroot_mnist
chroot_cleanup

lxc_setup
lxc_sysbench
lxc_ycruncher
lxc_dd
lxc_bonnie
lxc_cleanup

docker_setup
docker_sysbench
docker_ycruncher
docker_dd
docker_bonnie
docker_mnist
docker_cleanup

rkt_setup
rkt_sysbench
rkt_ycruncher
rkt_dd
rkt_bonnie
rkt_mnist
rkt_cleanup

system_cleanup

# sudo docker build -f Dockerfile_sysbench -t cloudml_sysbench .
# sudo docker tag cloudml_sysbench nisargthakkar/cloudml_sysbench
# sudo docker push nisargthakkar/cloudml_sysbench

# sudo docker build -f Dockerfile_ycruncher -t cloudml_ycruncher .
# sudo docker tag cloudml_ycruncher nisargthakkar/cloudml_ycruncher
# sudo docker push nisargthakkar/cloudml_ycruncher

# sudo docker build -f Dockerfile_dd -t cloudml_dd .
# sudo docker tag cloudml_dd nisargthakkar/cloudml_dd
# sudo docker push nisargthakkar/cloudml_dd

# sudo docker build -f Dockerfile_bonnie -t cloudml_bonnie .
# sudo docker tag cloudml_bonnie nisargthakkar/cloudml_bonnie
# sudo docker push nisargthakkar/cloudml_bonnie

# sudo docker build -t cloudml_mnist ../mnist-benchmark
# sudo docker tag cloudml_mnist nisargthakkar/cloudml_mnist
# sudo docker push nisargthakkar/cloudml_mnist
# sudo docker rmi cloudml_mnist

# TODO:
# * chroot ycruncher
