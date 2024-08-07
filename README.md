# Miele-LXIV Build System

Copyright &copy; Alex Bettarini, 2019-2024

---

The purpose of this project is to assist in setting up and configuring all dependencies for the project [Miele-LXIV](https://github.com/bettar/miele-lxiv).

In other words, <b>the goal of this project is NOT to build Miele-LXIV, but to create and configure the Xcode project that builds Miele-LXIV</b>.

The directory where this README.md file has been downloaded shall be referred to as `EASY_HOME`

Additionally, you must define the three top-level directories involved in the process (or conveniently accept the suggested defaults in STEP 1 below):

1. *sources*: `SRC` where all the source files will be downloaded
2. *build*: `BLD` temporary location for intermediate files
3. *install*: `BIN` the Xcode project will reference 3rd party modules installed here

---
### Prerequisite tools:

- kconfig-mconf

	This is a tool normally used in Linux systems to rebuild the kernel with a custom configuration. It was chosen because it creates configuration files that work well with shell scripts.<br />
	It's probably possible to install it from [sources](http://distortos.org/documentation/building-kconfig-frontends-linux/), and the dependencies can be installed using brew (gperf ncurses flex bison).<br />
	 Instead, I found it very convenient to install it like in the [NuttX](https://bitbucket.org/nuttx/) project:
	
		$ mkdir -p $SRC/nuttx
		$ cd $SRC/nuttx		
		
		$ cd $SRC/nuttx/tools/kconfig-frontends
		$ ./configure --disable-shared --enable-static --disable-gconf --disable-qconf --disable-nconf --disable-utils
		$ make
		$ sudo make install
		$ which kconfig-mcon

- wget
- cmake

	`CMake` is the GUI application, whereas `cmake` is the CLI utility that we need. If the command `$ which cmake` doesn't return anything, you can install it either with brew:
	
		$ brew install cmake
		
	or from the GUI package:
	
		$ sudo "/Applications/CMake.app/Contents/bin/cmake-gui" --install

		
---
### STEP 1: Once-only configuration

- Assuming the file `$EASY_HOME/seed.conf` hasn't been created yet, do the following:

		$ cd $EASY_HOME
		$ ./build.sh
	
	If you are brave or have the need for it, define and select your own version set file. I suggest you don't change anything, to get a default, tried and tested setup.

	- Save, Ok, Exit
	- Exit

	![step1](img/step1.png)

---
### STEP 2: Download sources

- This is also a step that should be run once only:

		$ ./reconfigure.sh

	- enable "Download sources" and possibly disable all other steps
	- Save, Ok, Exit
	- Exit

	![step2](img/step2.png)

	Run the shell script that carries out the downloads:

		$ ./build.sh

---
### STEP 3: Build and install the toolkits

- If everything goes smoothly this step is also done once only:

		$ ./reconfigure.sh

	- If "Download sources" is enabled, disable it: you don't want to download everything again.
	- Enable: Configure, Build, Install
	- Save, Ok, Exit
	- Exit

	![step3](img/step3.png)

	Run the shell script. This step will run for about one hour. To capture possible errors and warnings, save the output to a log file:

		$ script log/$(date +%Y%m%d_%H%M).txt
		$ ./build.sh ; exit

---
### STEP 4: Make installed toolkits available to Xcode project

- This step sets up the `Binaries` directory of the Xcode project

		$ ./reconfigure.sh

	- Enable only "Create Symbolic links"
	- Save, Ok, Exit
	- Exit

	![step4](img/step4.png)

	Run the shell script.

		$ ./build.sh

---
### STEP 5: Final "workaround" for Xcode

While STEPS 1..4 are nicely engineered to configure the project, there still remains some fixup to be done manually. This extra step will soon disappear, being replaced by a more elegant *behind the scenes* action. For the time being, please make the effort of doing what is explained in the link below.

- [version-set-8.8](version-set-8.8.step5.md)

---

### Conclusion 
- Now the goal of setting up the Xcode project that builds Miele-LXIV has been reached. You should be able to build the application from Xcode, make your modifications to the source files, and start your usual development cycle.
- If you prefer to work from the Command line, open up Terminal and re-build the project like this:

		$ xcodebuild -configuration Development -target miele-lxiv
		
	Note that one of the advantages of building the Development version is that it will NOT be sandboxed.

- If you want to reclaim some disk space you can safely remove the `miele-...` subdirectory in $BLD.

