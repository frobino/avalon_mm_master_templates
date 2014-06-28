avalon_mm_master_templates
==========================

avalon memory mapped master templates, based on a old post, refined and ported to QSYS

From thread [1], it is possible to download a very generic project implementing 
avalon memory mapped master templates, thanks to the user Graham. 
Unfortunately, the script gave me some troubles and I have modified the downloaded code, 
so that:

- simulation is automated
- the script is ported to QSYS

The structure of this project is very well done, and I want to use it as a reference 
to release future projects involving Altera's tools.


[1] http://www.alteraforum.com/forum/showthread.php?t=19053


To be done
==========================

- the generate_sim.sh does not work fully. This is beacuse the sopc_builder command 
  does not generate simulation files (e.g. setup_sim.do, ...)
- to make it work, run the script once, then run "sopc_builder test.sopc" and geneerate simulation from there. 
  Then just continue flow from there... this should be fixed...
- port to qsys changing the sopc_builder command in generate_sim.sh
- the 