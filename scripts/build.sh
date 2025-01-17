#!/bin/bash
PWD=$(pwd)

echo "请选择构建设备："
echo "1. AX1800"
echo "2. AXT1800"
read input

case $input in
1)
		echo "构建AX1800"
		DEVICE="ax1800"
		;;
2)
		echo "构建AXT1800"
		DEVICE="axt1800"
		;;
esac

#clone source tree
git clone https://github.com/gl-inet/gl-infra-builder.git $PWD/gl-infra-builder
cp -r $PWD/gl-infra-builder/*.yml $PWD/gl-infra-builder/profiles
cd $PWD/gl-infra-builder
#setup
python3 setup.py -c config-wlan-ap-5.4.yml

cd $PWD/gl-infra-builder
./scripts/gen_config.py  $PWD/gl-infra-builder/profiles/glinet_$DEVICE glinet_depends

#cd $PWD/gl-infra-builder
#./scripts/gen_config.py target_wlan_ap-gl-$DEVICE1 glinet_depends




git clone https://github.com/gl-inet/glinet4.x.git -b main $PWD/glinet
./scripts/feeds update -a
./scripts/feeds install -a
cp $PWD/glinet/pkg_config/gl_pkg_config_axt1800.mk  $PWD/glinet/ipq60xx/gl_pkg_config.mk
cp $PWD/glinet/pkg_config/glinet_depends_axt1800.yml  $PWD/gl-infra-builder/profiles/glinet_depends.yml
echo "$(date +"%Y.%m.%d")" >./package/base-files/files/etc/glversion
echo " Bulid By NiePeiLiang " >./package/base-files/files/etc/version.type
make defconfig


make -j$(expr $(nproc) + 1) GL_PKGDIR=$PWD/glinet/ipq60xx/ V=s
