function N = lookup_aolp_cylinder(aolp)

nsteps = 1000;
lut_x1 = linspace(0, pi/2, nsteps);
lut_x2 = linspace(pi/2+0.001, pi, nsteps);
lut_y1 = pi/2 - lut_x1;
lut_y2 = 3 * pi / 2 - lut_x2;
lut_x = [lut_x1, lut_x2];
lut_y = [lut_y1, lut_y2];
  
x_val = zeros(size(aolp));
y_val = zeros(size(aolp));
z_val = zeros(size(aolp));

x_val_vect = cos(interp1(lut_x, lut_y, aolp(:)));
y_val_vect = sin(interp1(lut_x, lut_y, aolp(:)));
x_val = reshape(x_val_vect, size(aolp));
y_val = reshape(y_val_vect, size(aolp));

N = zeros(size(x_val, 1), size(x_val, 2), 3);
N(:, :, 1) = x_val;
N(:, :, 2) = z_val;
N(:, :, 3) = y_val;