To get elmfire up and running, the only thing required is to install miniconda3 and run the load_elmfire.sh bash script using the source command: 
"source load_elmfire.sh" HOWEVER, make sure that the scratch directory is correctly noted.

Then build the elmfire model and tool as follows:
cd $ELMFIRE_BASE_DIR/build/linux
./make_gnu.sh

When running simulations, ensure that the scratch and Path_to_GDAL directory are correctly entered in both the data and the bash files. 
