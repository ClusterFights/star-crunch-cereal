export GPIO_BASE=""
grep -E '/soc/gpio|bcm2708_gpio' /proc/iomem &&\
export GPIO_BASE="-DGPIO_BASE=(0x"$(grep -E '/soc/gpio|bcm2708_gpio' /proc/iomem|sed -s 's/-.*//')")"
echo GPIO_BASE=$GPIO_BASE
