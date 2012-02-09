all:
	g++ -O2 -shared -w -o spectrum.so -I./ -I./amx/ -DLINUX *.cpp
