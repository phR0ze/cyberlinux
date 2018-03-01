# Chromebook

## Brightness
Brightness is controlled via the sysfs file ***/sys/class/backlight/intel_backlight/brightness***
with a max value of ***1200***

Manually change:

```bash
sudo tee /sys/class/backlight/intel_backlight/brightness <<< 800
```
