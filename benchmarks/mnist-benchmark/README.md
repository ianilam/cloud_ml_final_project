uses cProfile and outputs stats into "/logs"

to look at the stats

```
import pstats
p = pstats.Stats([outputfile_name])
p.strip_dirs().sort_stats('cumulative').print_stats(10)
```
