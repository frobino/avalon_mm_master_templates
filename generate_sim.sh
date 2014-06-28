# Script for simulation of custom component
# Generates SOPC System, Builds software and runs Modelsim
# Generate SOPC system if it does not already exist
if [ ! -f test.vhd ]
then
	echo "Generating SOPC System"
	sopc_builder --generate=1
fi

# Generate BSP if it doesn't exist
if [ ! -f ./software/bsp/public.mk ]
then
	nios2-bsp hal ./software/bsp  \
		--set hal.enable_sim_optimize true \
		--set hal.enable_small_c_library true \
		--set hal.enable_reduced_device_drivers true \
		--set hal.make.bsp_cflags_optimization -O3
else
	echo "skipping BSP generation because it already exits"
	echo " delete ./software/bsp dir to force regeneration"
fi
	
# Generate application makefile
nios2-app-generate-makefile --bsp-dir ./software/bsp \
	--app-dir ./software/app \
	--src-dir ./software/app/src \
	--set QUARTUS_PROJECT_DIR ../../ \
	--set APP_CFLAGS_OPTIMIZATION -O3
	
# Build software
pushd ./software/app
make mem_init_install
popd

# Open Modelsim and run sim script
pushd ./test_sim
vsim -do "do ../sim.do" &
popd
