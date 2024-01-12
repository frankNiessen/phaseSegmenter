# imadjust3
IMADJUST3 Adjust image intensity values for N-D images (supports gpuArray).
## Syntax
```matlab
J = IMADJUST3(I)
J = IMADJUST3(I, PERCENT)
J = IMADJUST3(I, [LOW_IN; HIGH_IN])
J = IMADJUST3(I, INLEVEL, [LOW_OUT; HIGH_OUT])
J = IMADJUST3(I, INLEVEL, [LOW_OUT; HIGH_OUT])
J = IMADJUST3(I, INLEVEL, [LOW_OUT; HIGH_OUT], GAMMA)
J = IMADJUST3(I, INLEVEL, [LOW_OUT; HIGH_OUT], GAMMA, USESINGLE)
GPUARRAYB = IMADJUST3(GPUARRAYA, ___)
```
## Description
`J = IMADJUST3(I)` maps the intensity values in a N-D grayscale image `I`
to new values in `J` such that 1% of data is saturated (Note that
imadjust defaults to 2%). This increases the constrast of the output
image `J`.

`J = IMADJUST3(I, PERCENT)` maps the intensity values in `I` to new values
in `J` such that the given `PERCENT` percentage of the image is saturated.
This increases the constrast of the output image `J`.

`J = IMADJUST3(I, INLEVEL, [LOW_OUT; HIGH_OUT])` maps the
values in intensity image `I` to new values in `J` such that values between
boundaries map to values between `LOW_OUT` and `HIGH_OUT`. `INLEVEL` can be a
percentage as described above or a vector with `[LOW_IN; HIGH_IN]`
supplied directly. Values below `LOW_IN` and above `HIGH_IN` are clipped
that is, values below `LOW_IN` map to `LOW_OUT`, and those above `HIGH_IN`
map to `HIGH_OUT`. You can use an empty matrix (`[]`) for `[LOW_IN; HIGH_IN]`
or for `[LOW_OUT; HIGH_OUT]` to specify the default of `[0 1]`. If you omit
the argument, `[LOW_OUT; HIGH_OUT]` defaults to `[0 1]`.

`J = IMADJUST3(I, INLEVEL ,[LOW_OUT; HIGH_OUT], GAMMA)` maps the
values of `I` to new values in `J` as described in the previous syntax.
`GAMMA` specifies the shape of the curve describing the relationship
between the values in `I` and `J`. If `GAMMA` is less than 1, the mapping is
weighted toward higher (brighter) output values. If `GAMMA` is greater
than 1, the mapping is weighted toward lower (darker) output values. If
you omit the argument, `GAMMA` defaults to 1 (linear mapping).

`J = IMADJUST3(IMADJUST3(I, INLEVEL, [LOW_OUT; HIGH_OUT], GAMMA,
USESINGLE)` forces single precision in case the input is an integer
datatype. This limits memory usage especially when working with
`gpuArray`.

Note that if `HIGH_OUT` < `LOW_OUT`, the output image is reversed, as in a
photographic negative.


## Class Support
The input image can be `uint8`, `uint16`, `int16`, `double`, `single` or a
`gpuArray` with one of these datatypes underlying. The output image has
the same class as the input image.

## Examples
Adjust Contrast of a N-D Grayscale Image
Read a low-contrast 4-D grayscale image into the workspace and display
a montage of it.
```matlab
vol = load('mri');
figure;
subplot(1,2,1);
montage(vol.D);
title('Original image volume');
```

![Original image volume](html/imadjust3_doc_01.png)

Adjust the contrast of  the image so that 1% of all voxels are
saturared and display a montage of it.
```matlab
volAdj = imadjust3(vol.D);
subplot(1,2,2);
montage(volAdj);
title('1% of voxels saturated')
```

![1% of voxels saturated](html/imadjust3_doc_02.png)

Adjust Contrast of a N-D Grayscale Image by Saturating a given
Percentage of Image Elements.
Read a low-contrast 4-D grayscale image into the workspace and display
a montage of it.
```matlab
vol = load('mri');
figure
subplot(1,2,1);
montage(vol.D);
title('Original image volume');
```

![Original image volume](html/imadjust3_doc_03.png)

Adjust the contrast of  the image so that 0.1% of all voxels are
saturared and display a montage of it.
```matlab
volAdj = imadjust3(vol.D, 0.001);
subplot(1,2,2);
montage(volAdj);
title('0.1% of voxels saturated')
```

![0.1% of voxels saturated](html/imadjust3_doc_04.png)

Adjust Contrast of a N-D Grayscale Image Specifying Contrast Limits
Read a low-contrast 4-D grayscale image into the workspace and display
a montage of it.
```matlab
vol = load('mri');
figure
subplot(1,2,1);
montage(vol.D);
title('Original image volume');
```

![Original image volume](html/imadjust3_doc_05.png)

Adjust the contrast of  the image, specifying contrast limits
```matlab
volAdj = imadjust3(vol.D, [0.3 0.7]);
subplot(1,2,2);
montage(volAdj);
title('Specified contrast limits [0.3 0.7]')
```

![Specified contrast limits 0.3 and 0.7](html/imadjust3_doc_06.png)

Adjust Contrast of a N-D Grayscale Image specifying non-linear Gamma
Read a low-contrast 4-D grayscale image into the workspace and display
a montage of it.
```matlab
vol = load('mri');
figure
subplot(1,2,1);
montage(vol.D);
title('Original image volume');
```

![Original image volume](html/imadjust3_doc_07.png)

Adjust the contrast of  the image, specifying a gamma value
```matlab
volAdj = imadjust3(vol.D, [], [], 0.5);
subplot(1,2,2);
montage(volAdj);
title('Specified gamma of 0.5')
```

![Specified gamma of 0.5](html/imadjust3_doc_08.png)

Adjust Contrast of a N-D Grayscale Image
Read a low-contrast 4-D grayscale image into a gpuArray and display
a montage of it.
```matlab
vol = load('mri');
D = gpuArray(vol.D);
figure
subplot(1,2,1);
montage(D);
title('Original image volume');
```

![Original image volume](html/imadjust3_doc_09.png)

Adjust the contrast of  the image so that 1% of all voxels are
saturared and display a montage of it.
```matlab
DAdj = imadjust3(D);
subplot(1,2,2);
montage(volAdj);
title('1% of voxels saturated, computed on the GPU')
```

![1% of voxels saturated, computed on the GPU](html/imadjust3_doc_10.png)

## Input Arguments

| I -- Image to be adjusted (gpuArray supported) |
| ---------------------------------------------- |
| grayscale N-D image |
| Data Types: single &#124; double &#124; int16 &#124; uint8 &#124; uint16 &#124; uint32 &#124; gpuArray (with the previous underlying data types) |

| INLEVEL -- PERCENT or [LOW_IN, HIGH_IN] - Contrast limits |
| --------------------------------------------------------- |
| 0.01 (Default) &#124; scalar between 0 and 1 &#124; [0 1] (Default for empty entry) &#124; two-element numeric vector with values between 0 and 1
| Contrast limits either as a percentage of pixels to be saturated or as direct lower and upper limits. Values below LOW_IN and above HIGH_IN are clipped; that is, values below LOW_IN map to LOW_OUT, and those above HIGH_IN map to HIGH_OUT. If you specify an empty matrix ([]), imadjust3 uses the default limits [0 1]. If only an image is supplied imadjust3 will saturate 1% of image elements. |
| Data Types: double |

| OUTLEVEL -- Contrast limits for output image |
| -------------------------------------------- |
| [0 1] (Default) &#124; two-elment numeric vector with values between 0 and 1 |
| Contrast limits for the output image, specified as a two-element numeric vector with values between 0 and 1. Values below low_in and above high_in are clipped; that is, values below low_in map to low_out, and those above high_in map to high_out. If you specify an empty matrix ([]), imadjust3 uses the default limits [0 1]. |
| Data Types: double |

| GAMMA -- Shape of the curve describing relationship of input and output values |
| ------------------------------------------------------------------------------ |
| 1 (default) &#124; double real scalar |
| Shape of curve describing relationship of input and output values, specified as a numeric value. If gamma is less than 1, imadjust weights the mapping toward higher (brighter) output values. If gamma is greater than 1, imadjust weights the mapping toward lower (darker) output values. If you omit the argument, gamma defaults to 1 (linear mapping). |
| Data Types: double |

| USESINGLE -- Scalar bool flag to indicate whether to use single precision for integer based images |
| ------------------ |
| false (default) &#124; bool scalar |
| In case of integer format images double precision is not always necessary. A true scalar will force imadjust3 to use single precision for these image types thus saving memory. |
| Data Types: logical &#124; numeric |

## Output Arguments

| J -- Adjusted image (gpuArray supported) |
| ---------------------------------------- |
| grayscale N-D image |
| Adjusted image, returned as a grayscale image. J has the same class as the input image. |
| Data Types: single &#124; double &#124; int16 &#124; uint8 &#124; uint16 &#124; uint32 &#124; gpuArray (with the previous underlying data types) |

## See Also
imadjust
