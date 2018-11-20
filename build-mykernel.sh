#!/bin/bash
# Script to build kernel zip for arm64 devices to flash using recovery
# Script by Nidhun Balaji T R <nidhunbalaji@gmail.com>
# nibaji @github

start_time=$(date +'%s')

#initialise colours
r="\e[30;48;5;160m"
r1="\e[40;38;5;160m"
g="\e[30;48;5;82m"
g1="\e[40;38;5;82m"
b="\e[30;48;5;20m"
b1="\e[40;38;5;20m"
o="\e[0m"
echo -e "$g1 My $g  Kernel  $o"
for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo

#initialise working directories and some variables
mykernel_dir="$("pwd")/../mykernel-working"
kernel_srcs="$mykernel_dir/kernel_srcs"
toolchains="$mykernel_dir/toolchains"
out_dir="$mykernel_dir/out"
zip_dir="$mykernel_dir/zip"
if [ ! -d "$mykernel_dir" ]
    then
    mkdir $mykernel_dir
fi
if [ ! -d "$kernel_srcs" ]
    then
    mkdir $kernel_srcs
fi
if [ ! -d "$toolchains" ]
    then    
    mkdir $toolchains
fi
if [ ! -d "$out_dir" ]
    then
    mkdir $out_dir
fi
if [ ! -d "$zip_dir" ]
    then
    mkdir $zip_dir
fi

#get device_name
echo -e "$r Give your device codename $o$g without spaces $o"
read device_name

#get kernel src
echo -e "$r Have you already downloaded/extracted/cloned the kernel source? $o"
echo -e "yes - $g y $o"
echo -e "no - $g n $o"
read ans
if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
    then
    #get kernel src folder that has akready been downloaded/extracted/cloned
    echo -e "$g Copy and paste your kernel source folder location $o"
    read kernel_folder
    for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
    if [ "$(realpath "$kernel_folder")" == "$(realpath "$kernel_srcs/$(basename "$kernel_folder")")" ]
    then
        echo -e "$g You have the source in right location $o"
        for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
        cd $kernel_srcs
        #to get it read as recently modified folder for $kernel_src
        touch idkwts
        cp idkwts $(basename "$kernel_folder")
        rm $(basename "$kernel_folder")/idkwts idkwts
    else
        echo -e "$g Copying your source to mykernel working directory..... $o"
        cp -rf $kernel_folder $kernel_srcs
        for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
        cd $kernel_srcs
    fi
elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
    then
    #get kernel src git link
    echo -e "$g Link your kernel source $o"
    read kernel_git
    #get branch
    echo -e "$r Specify the branch to clone $o$g Leave it blank and presss enter if you just wanna use the default branch $o"
    read kernel_branch
    #clone repo
    cd $kernel_srcs
    if [ -z $kernel_branch ] #assert if branch is specified or not
        then
        echo -e "$g Cloning $o$b default branch.. $o"
        git clone $kernel_git
    else
        echo -e "$g Cloning $o$b $kernel_branch .. $o"
        git clone $kernel_git -b $kernel_branch
    fi
else
    echo -e "$r What do you mean? $o"
    exit
fi

#make use of the folder name as kernel src var.| Recently modded folder name, cutting '/'
kernel_src=$kernel_srcs/$(ls -td -- */ | head -n 1 | cut -d'/' -f1)
cd ..

#choosing defconfig
echo -e "$g Specify the defconfig to make $o$b Copy paste one among the following $o"
ls $kernel_src/arch/arm64/configs
for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
read def_config

#toolchain options
for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
echo -e "$r Choose a toolchain to cross compile $o"
echo -e "1 $b AOSP-GCC $o $r (4.9) $o"
echo -e "2 $b ARM-GNU-GCC $o $r (8.2) $o"
echo -e "3 $b Bootlin $o $r (Stable - gcc 6.4.0 & Bleeding Edge - gcc 8.2.0) $o"
echo -e "4 $b Linaro $o $r (7.3.1) $o"
echo -e "5 $r Custom/Unlisted toolchain $b(Have it extracted to a folder)$o $o"
echo -e "Specify a number"
read tc_opt

#get toolchain
cd $toolchains
if [ $tc_opt -eq 1 ] #aosp-gcc
    then
    echo -e "$g You chose AOSP-GCC $o"
    for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
    tc=aosp_gcc
    if [ -d "aarch64-linux-android-4.9" ]
        then
        echo -e "$r Toolchain has already been cloned? $o"
        echo -e "yes -$g y $o"
        echo -e "no - $g n $o"
        read ans
        if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
            then
            toolchain_dir="$toolchains/aarch64-linux-android-4.9"
            cc="$toolchain_dir/bin/aarch64-linux-android-"
        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
            then
            echo -e "$g Getting the source $o"
            rm -rf aarch64-linux-android-4.9
            git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
            toolchain_dir="$toolchains/aarch64-linux-android-4.9"
            cc="$toolchain_dir/bin/aarch64-linux-android-"
        else
            echo -e "$r What do you mean? $o"
            exit
        fi
    else
        echo -e "$g Getting the source $o"
        git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
        toolchain_dir="$toolchains/aarch64-linux-android-4.9"
        cc="$toolchain_dir/bin/aarch64-linux-android-"
    fi
    
elif [ $tc_opt -eq 2 ] #arm-gnu-gcc
    then
    echo -e "$r You chose ARM-GNU-GCC $o"
    for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
    tc=arm_gnu_gcc
    if [ -d  "gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu" ]
        then
        echo -e "$r You already have downloaded and extracted the toolchain? $o"
        echo -e "yes - $g y $o"
        echo -e "no - $g n $o"
        read ans
        if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
            then
            toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
            then
            echo -e "$r You already have downloaded the toolchain tarball? $o"
            echo -e "yes - $g y $o"
            echo -e "no - $g n $o"
            read ans
            if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                then
                echo -e "$g Extracting $o"
                tar xf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
                toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
                cc="$toolchain_dir/bin/aarch64-linux-gnu-"
            elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                then
                rm -rf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-*
                echo -e "$g Getting the source $o"
                wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2018.08/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
                echo -e "$g Extracting $o"
                tar xf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
                toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
                cc="$toolchain_dir/bin/aarch64-linux-gnu-"
            else
                echo -e "$r What do you mean? $o"
                exit
            fi
        else
            rm -rf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-*
            echo -e "$g Getting the source $o"
            wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2018.08/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
            echo -e "$g Extracting $o"
            tar xf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
            toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        fi
    elif [ -f  "gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz" ]
        then
        echo -e "$r You already have downloaded the toolchain tarball? $o"
        echo -e "yes - $g y $o"
        echo -e "no - $g n $o"
        read ans
        if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
            then
            echo -e "$g Extracting $o"
            tar xf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
            toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
            then
            echo
            rm -rf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-*
            echo -e "$g Getting the source $o"
            wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2018.08/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
            echo -e "$g Extracting $o"
            tar xf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
            toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        else
            echo -e "$r What do you mean? $o"
            exit
        fi
    else
        echo -e "$g Getting the source $o"
        wget https://developer.arm.com/-/media/Files/downloads/gnu-a/8.2-2018.08/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
        echo -e "$g Extracting $o"
        tar xf gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu.tar.xz
        toolchain_dir="$toolchains/gcc-arm-8.2-2018.08-x86_64-aarch64-linux-gnu"
        cc="$toolchain_dir/bin/aarch64-linux-gnu-"
    fi
    
elif [ $tc_opt -eq 3 ] #bootlin
    then
    echo -e "$g You chose Bootlin $o"
    for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
    echo -e "$r Choose Bootlin version $o"
    echo -e "1 $b  Bleeding Edge - gcc 8.2.0 $o"
    echo -e "2 $b  Stable - gcc 6.4.0 $o"
    read tc_br_opt
        if [ $tc_br_opt -eq 1 ] #bleeding edge bootlin
            then
            echo -e "$g You chose Bleeding Edge Bootlin $o"
            for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
            tc=bootlin_bleeding_edge
            if [ -d  "aarch64--glibc--bleeding-edge-2018.07-3" ]
                then
                echo -e "$r You already have downloaded and extracted the toolchain? $o"
                echo -e "yes - $g y $o"
                echo -e "no - $g n $o"
                read ans
                if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                    then
                    toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.07-3"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                    then
                    echo -e "$r You already have downloaded the toolchain tarball? $o"
                    echo -e "yes - $g y $o"
                    echo -e "no - $g n $o"
                    read ans
                    if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                        then
                        echo -e "$g Extracting $o"
                        tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                        toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.02-2"
                        cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                        then
                        rm -rf aarch64--glibc--bleeding-edge-*
                        echo -e "$g Getting the source $o"
                        wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                        echo -e "$g Extracting $o"
                        tar xf aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                        toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.07-3"
                        cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                    else
                        echo -e "$r What have you done $o"
                    fi
                else
                    rm -rf aarch64--glibc--bleeding-edge-*
                    echo -e "$g Getting the source $o"
                    wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                    echo -e "$g Extracting $o"
                    tar xf aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                    toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.07-3"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                fi
            elif [ -f  "aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2" ]
                then
                echo -e "$r You already have downloaded the toolchain tarball? $o"
                echo -e "yes - $g y $o"
                echo -e "no - $g n $o"
                read ans
                if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                    then
                    echo -e "$g Extracting $o"
                    tar xf aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                    toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.07-3"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                    then
                    rm -rf aarch64--glibc--bleeding-edge-*
                    echo -e "$g Getting the source $o"
                    wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                    echo -e "$g Extracting $o"
                    tar xf aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                    toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.07-3"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                else
                    echo -e "$r What do you mean? $o"
                    exit
                fi
            else
                wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                echo -e "$g Extracting $o"
                tar xf aarch64--glibc--bleeding-edge-2018.07-3.tar.bz2
                toolchain_dir="$toolchains/aarch64--glibc--bleeding-edge-2018.07-3"
                cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
            fi
        elif [ $tc_br_opt -eq 2 ] #stable bootlin
            then
            echo -e "$g You chose Stable Bootlin $o"
            for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
            tc=bootlin_stable
            if [ -d  "aarch64--glibc--stable-2018.02-2" ]
                then
                echo -e "$r You already have downloaded and extracted the toolchain? $o"
                echo -e "yes - $g y $o"
                echo -e "no - $g n $o"
                read ans
                if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                    then
                    toolchain_dir="$toolchains/aarch64--glibc--stable-2018.02-2"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                    then
                    echo -e "$r You already have downloaded the toolchain tarball? $o"
                    echo -e "yes - $g y $o"
                    echo -e "no - $g n $o"
                    read ans
                    if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                        then
                        echo -e "$g Extracting $o"
                        tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                        toolchain_dir="$toolchains/aarch64--glibc--stable-2018.02-2"
                        cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                        then
                        rm -rf aarch64--glibc--stable-*
                        echo -e "$g Getting the source $o"
                        wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2018.02-2.tar.bz2
                        echo -e "$g Extracting $o"
                        tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                        toolchain_dir="$toolchains/aarch64--glibc--stable-2018.02-2"
                        cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                    else
                        echo -e "$r What have you done $o"
                    fi
                else
                    rm -rf aarch64--glibc--stable-*
                    echo -e "$g Getting the source $o"
                    wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2018.02-2.tar.bz2
                    echo -e "$g Extracting $o"
                    tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                    toolchain_dir="$toolchains/aarch64--glibc--stable-2018.02-2"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                fi
            elif [ -f  "aarch64--glibc--stable-2018.02-2.tar.bz2" ]
                then
                echo -e "$r You already have downloaded the toolchain tarball? $o"
                echo -e "yes - $g y $o"
                echo -e "no - $g n $o"
                read ans
                if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                    then
                    echo -e "$g Extracting $o"
                    tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                    toolchain_dir="$toolchains/stable-2018.02-2"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                    then
                    rm -rf aarch64--glibc--stable-*
                    echo -e "$g Getting the source $o"
                    wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2018.02-2.tar.bz2
                    echo -e "$g Extracting $o"
                    tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                    toolchain_dir="$toolchains/aarch64--glibc--stable-2018.02-2"
                    cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
                else
                    echo -e "$r What do you mean? $o"
                    exit
                fi
            else
                wget https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2018.02-2.tar.bz2
                echo -e "$g Extracting $o"
                tar xf aarch64--glibc--stable-2018.02-2.tar.bz2
                toolchain_dir="$toolchains/aarch64--glibc--stable-2018.02-2"
                cc="$toolchain_dir/bin/aarch64-buildroot-linux-gnu-"
            fi
        else
            echo -e "$r What do you mean? $o"
            exit
        fi
        
elif [ $tc_opt -eq 4 ] #linaro
    then
    echo -e "$g You chose linaro $o"
    for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
    tc=linaro
    if [ -d  "gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu" ]
        then
        echo -e "$r You already have downloaded and extracted the toolchain? $o"
        echo -e "yes - $g y $o"
        echo -e "no - $g n $o"
        read ans
        if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
            then
            toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
            then
            echo -e "$r You already have downloaded the toolchain tarball? $o"
            echo -e "yes - $g y $o"
            echo -e "no - $g n $o"
            read ans
            if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
                then
                echo -e "$g Extracting $o"
                tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
                toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
                cc="$toolchain_dir/bin/aarch64-linux-gnu-"
            elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
                then
                rm -rf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-*
                echo -e "$g Getting the source $o"
                wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
                echo -e "$g Extracting $o"
                tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
                toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
                cc="$toolchain_dir/bin/aarch64-linux-gnu-"
            else
                echo -e "$r What have you done $o"
            fi
        else
            rm -rf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-*
            echo -e "$g Getting the source $o"
            wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
            echo -e "$g Extracting $o"
            tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
            toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        fi
    elif [ -f  "gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz" ]
        then
        echo -e "$r You already have downloaded the toolchain tarball? $o"
        echo -e "yes - $g y $o"
        echo -e "no - $g n $o"
        read ans
        if [ "$ans" == "y" ] || [ "$ans" == "Y" ]
            then
            echo -e "$g Extracting $o"
            tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
            toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        elif [ "$ans" == "n" ] || [ "$ans" == "N" ]
            then
            rm -rf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-*
            echo -e "$g Getting the source $o"
            wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
            echo -e "$g Extracting $o"
            tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
            toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
            cc="$toolchain_dir/bin/aarch64-linux-gnu-"
        else
            echo -e "$r What do you mean? $o"
            exit
        fi
    else
        echo -e "$g Getting the source $o"
        wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
        echo -e "$g Extracting $o"
        tar xf gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
        toolchain_dir="$toolchains/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu"
        cc="$toolchain_dir/bin/aarch64-linux-gnu-"
    fi

elif [ $tc_opt -eq 5 ] #custom toolchain/any other toolchain unlisted
    then
    echo -e "$r Copy paste the toolchain location below $o"
    read toolchain_dir
    echo -e "$r Mention the toolchain name (without spaces) $o"
    read tc
    cd "$toolchain_dir"/bin
    cc=""$toolchain_dir"/bin/$(ls -S *addr2line | grep -v ^l | sed 's/addr2line//')"

else
    echo -e "$r What was that $o"
    exit
fi

#time to build
for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
echo -e "$g Cleaning up directories $o"
rm -rf $out_dir
mkdir $out_dir
cd $kernel_src
for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
echo -e "$g Making defconfig $o"
make O=$out_dir ARCH=arm64 $def_config | pv -t
for i in {16..21} {21..16} ; do echo -en "\e[48;5;${i}m $o" ; done ; echo
echo -e "$g Compiling with $o$b $tc .. $o"
make -j$(nproc --all) O=$out_dir \
                      ARCH=arm64 \
                      SUBARCH=arm64 \
                      HEADER_ARCH=arm64 \
                      LD_LIBRARY_PATH="$toolchain_dir/lib" \
                      CROSS_COMPILE="$cc" | pv -t
built_time=$(date +'%Y%m%d-%H%M')

#zip it with AnyKernel2                      
if [ -f  "$out_dir/arch/arm64/boot/Image.gz-dtb" ]
    then
    echo -e "$b Done!! $o"
    echo -e "$g Fetching anykernel2.. $o"
    rm -rf $zip_dir
    git clone https://github.com/osm0sis/AnyKernel2 $zip_dir
    cd $zip_dir
    rm -rf modules patch ramdisk *.md
    cp  $out_dir/arch/arm64/boot/Image.gz-dtb $zip_dir
    mv Image.gz-dtb zImage
    sed -i 's/ExampleKernel by osm0sis @ xda-developers/mykernel/g' anykernel.sh
    sed -i 's/do.devicecheck=1/do.devicecheck=0/g' anykernel.sh
    sed -i 's/platform\/\omap\/\omap_hsmmc.0/bootdevice/g' anykernel.sh
    sed -i '/# AnyKernel file attributes/{/write_boot/!d;}' anykernel.sh
    sed -i '/ramdisk/{/write_boot/!d;}' anykernel.sh
    sed -i '/# begin ramdisk changes/{/write_boot/!d;}' anykernel.sh
    sed -i '/init/{/write_boot/!d;}' anykernel.sh
    sed -i '/fstab/{/write_boot/!d;}' anykernel.sh
    echo -e "$g zipping.. $o"
    zip -r9 mykernel-$tc-$device_name--$built_time *
    echo -e "$g mykernel is ready to be flashed. $o"
else
    echo -e "$r Check what has gone wrong and try again $o"
fi
cd $mykernel_dir

#time
end_time=$(date +'%s')
runtime_hr=$((("$end_time" - "$start_time")/3600))
runtime_min=$(((("$end_time" - "$start_time")/60)%60))
runtime_sec=$((("$end_time" - "$start_time")%60))
runtime="$r $runtime_hr $o$g1 h $o : $b $runtime_min $o$r1 m $o : $g $runtime_sec $o$b1 s $o"
echo -e "$g1 mykernel script ran for $o $runtime"
