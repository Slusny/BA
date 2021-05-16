# Linear depth estimation from an uncalibrated, monocular polarisation image

This is a Matlab implementation of our ECCV 2016 paper "Linear depth estimation from an uncalibrated, monocular polarisation image". It also includes an implementation of polarimetric image decomposition (linear and nonlinear optimisation), two comparison shape-from-polarisation methods, a simple least squares surface integration method (which supports a foreground mask) and a basic method for pixel-wise specular labelling.

Note: I am in the process of cleaning up the code and adding to the repository. I will update the list of what has been uploaded as I go along. Content included so far:

1. Comparison methods
2. Least squares integrator
3. Polarimetric image decomposition
4. Diffuse polarisation model (degree of polarisation to zenith angle)
5. Light source estimation
6. Height from polarisation

Still to add:

1. Specular model, specular labelling
2. Boundary prior (computing boundary azimuth and weight)
3. Sample datasets
4. Code for generating synthetic datasets and evaluating

I will add documentation and demo scripts as I upload the code.

## Polarimetric image decomposition

The first thing you need to do is convert your captured image into a 3-channel polarisation image. The function that does this is PolarisationImage.m. Inputs are:

1. images - 3D array containing captured images of size rows by cols by nimages
2. angles - vector of length nimages containing polariser angles (I use a coordinate system where the polariser angle is measured from the upward vertical axis, increasing in a clockwise direction if viewed looking into the camera lens)
3. (optional) mask - binary foreground mask of size rows by cols
4. (optional) method - either 'linear' or 'nonlinear', default: linear

It returns rho (degree of polarisation), phi (phase angle) and Iun (unpolarised intensity).

Sample call:

```matlab
[ rho,phi,Iun ] = PolarisationImages( images,angles,mask,'linear' );
figure; imagesc(rho); colorbar
figure; imagesc(phi); colorbar
figure; imshow(Iun)
```

## Convert degree of polarisation to zenith angle

For the time being, I only include the diffuse polarisation model. So to convert the degree of polarisation (rho) to a zenith angle, you simply do:

```matlab
theta = rho_diffuse(rho,n);
```

where n is the index of refraction (we use n=1.5 in the paper).

## Light source estimation

If you do not know your light source direction (or if you know it, but don't know the light source intensity/uniform albedo) then the next thing you need to do is estimate it. This is done using the findLight function. It can estimate point source or spherical harmonic order 1 or 2 lighting. A basic call for point source lighting where you don't know the direction would be:

```matlab
[ l,T,B ] = findLight( theta,phi,diffuse,mask,3 );
```

Alternatively, if you know the direction is [1 0 1] but need to scale to account for unknown intensity/albedo, then do:

```matlab
l = [1 0 1]'./norm([1 0 1]);
[ l,T,B ] = findLight( theta,phi,diffuse,mask,3,l );
```

For other options and spherical harmonic lighting, see the documentation.

## Computing depth

Finally, we are ready to compute depth. Again, this is the most basic call assuming only diffuse pixels:

```matlab
[ height ] = HfPol( theta,diffuse,phi,l,mask );
```

To display the height map, you can do, for example:

```matlab
figure; surf(height'); axis equal
```
