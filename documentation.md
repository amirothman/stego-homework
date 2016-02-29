#Digital Watermarking - Final Project


## How The System Works

The system pipeline proceeds as follow:

Input: WatermarkString, Channel, Image

WatermarkString
Channel: R,G,B
Image: Image to hold the message

WatermarkString --> toBits() --> WatermarkStringBits

(Channel, Image, WatermarkStringBits) --> embedBits() --> WatermarkedImage

(WatermarkedImage, Channel) --> getBits() --> WatermarkStringBits

WatermarkStringBits --> toString() --> WatermarkString

### toBits()

Convert String to bits

### toString()

Convert Bits to String

### embedBits()

    1. Subtract one from the pixels with odd value. At this point, all the pixels will have even value.
    2. Cyclically go through WatermarkStringBits and pixels of image. If WaterMarkStringBits has 1, add one. At this point, odd values on the pixels of the image is mapped to 1 value of the WaterMarkStringBits.

### getBits()



