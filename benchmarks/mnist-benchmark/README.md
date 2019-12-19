If running the mnist-benchmark test on Prince, use the following commond:

`time python -m cProfile -o cprofile_log1 main.py --epochs 1`

This program uses cProfile and outputs stats into "/logs".

To look at the stats:
```
import pstats
p = pstats.Stats([outputfile_name])
p.strip_dirs().sort_stats('cumulative').print_stats(10)
```

Example: 
```
Ians-MacBook-Air:logs ian$ python
Python 3.7.3 (default, Mar 27 2019, 16:54:48) 
[Clang 4.0.1 (tags/RELEASE_401/final)] :: Anaconda, Inc. on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import pstats
>>> p = pstats.Stats("mnist_profile")
>>> p.strip_dirs().sort_stats('cumulative').print_stats(10)
Mon Dec  9 23:48:35 2019    mnist_profile

         6210317 function calls (6186757 primitive calls) in 136.308 seconds

   Ordered by: cumulative time
   List reduced from 3269 to 10 due to restriction <10>

   ncalls  tottime  percall  cumtime  percall filename:lineno(function)
        2    0.007    0.003  136.317   68.159 main.py:1(<module>)
    855/1    0.036    0.000  136.311  136.311 {built-in method builtins.exec}
        1    0.000    0.000  132.306  132.306 main.py:70(main)
        1    0.068    0.068  120.247  120.247 main.py:36(train)
      938    0.010    0.000   60.377    0.064 tensor.py:138(backward)
      938    0.029    0.000   60.367    0.064 __init__.py:44(backward)
      938   60.306    0.064   60.306    0.064 {method 'run_backward' of 'torch._C._EngineBase' objects}
 6636/948    0.143    0.000   38.570    0.041 module.py:531(__call__)
      948    0.680    0.001   38.545    0.041 main.py:21(forward)
     1896    0.013    0.000   22.379    0.012 conv.py:344(forward)


```
