close all

pref_in  = input(' prefijo input (entre apostrofes)? ');
ini_in   = input('          numero inicial de input? ');
fprintf('se leeran las imagenes que empiecen con "%s" desde la %d...\n',pref_in,ini_in);
pref_out = input('prefijo output (entre apostrofes)? ');
ini_out  = input('          numero inicial de input? ');
fprintf('los patches seleccionados se grabaran como "%s_xxxxx.png" desde el numero x=%d...\n',pref_out,ini_out);
psize    = input('          tamano de patch (ej 20)? ');
n2       = round((psize+1)/2);
d        = dir([pref_in '*']);
ok       = 0;
k_ini    = ini_in;
k_out    = ini_out;
while not(ok)
    st = d(k_ini).name;
    I = imread(st);
    figure(1)
    clf
    imshow(I);
    title(st)
    [N,M] = size(I);
    hold on
    click = 1;
    while click
        figure(1)
        disp('click en figura 1...');
        [j,i] = ginput(1);
        disp('x')
        if (j>n2) && (i>n2) && (i<(N-n2)) && (j<(M-n2))
            z = I(i-n2:i-n2+psize-1,j-n2:j-n2+psize-1);
            figure(2)
            imshow(z)
            y = input('0:rechazar 1:aceptar 2:siguiente imagen? ');
            switch y
                case 0
                    disp('rechazado');
                case 1
                    figure(1)
                    plot(j,i,'r.');
                    st = [pref_out '_' num2fixstr(k_out,6) '.png'];
                    k_out = k_out+1;
                    fprintf('grabando patch %s...\n',st);
                    imwrite(z,st,'png');
                case 2
                    click = 0;
            end
        else
            beep
        end
    end
    k_ini = k_ini+1;
end
