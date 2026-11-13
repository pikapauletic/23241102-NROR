%%
clc;
clear;
%% Uvoz
vsebina = fileread("lopatica_mreza.txt");
vsebina_cista = strtrim(vsebina);
bloki = regexp(vsebina_cista,'\n\s*\n', 'split');
bloki;

tocke_char = bloki{1};
celice_char = bloki{2};

%%

function matrika_podatki = extract_podatki(char_podatki)

    %funkcija sprejme char blok poljubne oblique iz katere pobere podatke in
    %jih pretvori v matriko. funckija predvideva zgolj naslov v prvi
    %vrstici. 

    tocke_delitev = splitlines(char_podatki);
    tocke_podatki = tocke_delitev(2:end);
    L = split(tocke_podatki, [";", ","]);
    matrika_podatki = str2double(L);

end 

function [tip, temp, alfa, matrika_pogoji] = extract_pogoji(st_pogoja, char_pogoji)

    rp_delitev = splitlines(char_pogoji);

    if st_pogoja == 1

    rp_delitev = rp_delitev(2:end);

    end

tip_vektor = split(rp_delitev(1), ":");
tip = char(strtrim(tip_vektor(2)));

rp_temperatura_vektor = split(rp_delitev(2), ":");
temp = str2double(rp_temperatura_vektor(2));

if strcmp(tip, 'prestop')

    rp_prestop_vektor = split(rp_delitev(3), ":");
    alfa = str2double(rp_prestop_vektor(2));
    rp_podatki = rp_delitev(5:end);

else

    alfa = 0;
    rp_podatki = rp_delitev(4:end);

end

L = split(rp_podatki, [";", ","]);
matrika_pogoji = str2double(L);

end

celice = extract_podatki(celice_char);
tocke = extract_podatki(tocke_char);

%%

K = numel(bloki) - 2;

for i = 1:K

    [rp(i).tip, rp(i).temperatura, rp(i).prestop, rp(i).tocke] = extract_pogoji(i, bloki{i + 2});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Vizualizacija

x = tocke(:,2);
y = tocke(:,3);

X = [];                                   
Y = [];

for i = 1:size(celice, 1)

    celice_vrstica = celice(i, :);

    vozlisce_id_1 = celice_vrstica(2) + 1;
    vozlisce_id_2 = celice_vrstica(3) + 1;
    vozlisce_id_3 = celice_vrstica(4) + 1;
    vozlisce_id_4 = celice_vrstica(5) + 1;


    x1 = x(vozlisce_id_1);
    x2 = x(vozlisce_id_2);
    x3 = x(vozlisce_id_3);
    x4 = x(vozlisce_id_4);

    y1 = y(vozlisce_id_1);
    y2 = y(vozlisce_id_2);
    y3 = y(vozlisce_id_3);
    y4 = y(vozlisce_id_4);

    X = [X, x1 x2 x3 x4 x1 NaN];          
    Y = [Y, y1 y2 y3 y4 y1 NaN];
    

end 

close all;
figure;
hold on;
plot(X, Y, 'k-');


barve = {'r', 'y', 'b', 'm'}; 

for j = 1:K

    rp_vozlisce_id = rp(j).tocke + 1;

    vizualizacija_rp(j) = plot(x(rp_vozlisce_id), y(rp_vozlisce_id), 'o','MarkerFaceColor', barve{j}, 'MarkerEdgeColor', barve{j}, 'MarkerSize', 2);

    if strcmp(rp(j).tip, 'prestop')

        legenda{j} = sprintf('Robni pogoj %d: prestop, T = %g ºC, h = %g W/(m^2K)', j, rp(j).temperatura, rp(j).prestop);

    elseif strcmp(rp(j).tip, 'temperatura')

        legenda{j} = sprintf('Robni pogoj %d: T = %g ºC', j, rp(j).temperatura);
    
    else

        legenda{j} = sprintf('Robni pogoj %d: q = %g W/m^2', j, rp(j).temperatura);
    
    end

end

quiver(0, 0, 0.0025, 0, 0,  'k', 'LineWidth', 1.5, 'MaxHeadSize', 0.5)
quiver(0, 0, 0, 1, 0.0025, 'k', 'LineWidth', 1.5, 'MaxHeadSize', 0.5)

text(0.003, 0, 'x', 'FontWeight', 'normal', 'FontSize', 10)
text(0, 0.0032, 'y', 'FontWeight', 'normal', 'FontSize', 10)

hold off;

axis equal;
title('Vizualizacija diskretizirane lopatice plinske turbine');
xlabel('x [m]');
ylabel('y [m]');

legend(vizualizacija_rp, legenda, 'Location', 'best');

%% A in b

k = 22;
vrsta1_id = celice(1, 2:5) + 1;
dx = abs(x(vrsta1_id(3)) - x(vrsta1_id(2))) %podano, ampak ta velja zgolj za prvi primer! dx = dy

stevilo_vozlisc = size(tocke, 1);
stevilo_celic = size(celice, 1);

celice_na_tocko = zeros(stevilo_vozlisc, 1);

for i = 1:stevilo_celic

   vozlisca = celice(i, 2:5) + 1;
   celice_na_tocko(vozlisca) = celice_na_tocko(vozlisca) + 1;

end

notranje = find(celice_na_tocko == 4);
rob = find(celice_na_tocko == 2);
zunanji_kot = find(celice_na_tocko == 1);
notranji_kot = find(celice_na_tocko == 3);

robne_tocke = [];

for g = 1:K

    robne_tocke = [robne_tocke; rp(g).tocke];

end

robne_tocke = robne_tocke + 1;

%% sosedi

stolpci = round((x - min(x)) / dx) + 1;
vrstice = round((y - min(y)) / dx) + 1;

sosedi = zeros(stevilo_vozlisc, 4);

for i = 1:stevilo_vozlisc

    levo  = find(stolpci == stolpci(i)-1 & vrstice == vrstice(i));
    desno = find(stolpci == stolpci(i)+1 & vrstice == vrstice(i));
    dol   = find(stolpci == stolpci(i)   & vrstice == vrstice(i)-1);
    gor   = find(stolpci == stolpci(i)   & vrstice == vrstice(i)+1);

    if ~isempty(levo),  sosedi(i,1) = levo;  end
    if ~isempty(desno), sosedi(i,2) = desno; end
    if ~isempty(dol),   sosedi(i,3) = dol;   end
    if ~isempty(gor),   sosedi(i,4) = gor;   end

end

%% matrika

A = sparse(stevilo_vozlisc, stevilo_vozlisc);
b = zeros(stevilo_vozlisc, 1);
%notranjs vozlisca

for j = 1:size(notranje, 1)

    i = notranje(j);

    A(i, sosedi(i,:)) = 1;
    A(i, i) = -4;
    
    
end

% prestop

Bi_vozlisca = zeros(stevilo_vozlisc, 1);
Tinf_vozlisca = zeros(stevilo_vozlisc, 1);

for i = 1:K

    if strcmp(rp(i).tip, 'prestop')

        id = rp(i).tocke + 1;
        Bi_vozlisca(id) = (rp(i).prestop * dx)/k;
        Tinf_vozlisca(id) = rp(i).temperatura;
    
    end
end

%rob, koti

for j = 1:size(robne_tocke, 1)
    
    i = robne_tocke(j);
    Bi = Bi_vozlisca(i);
    s = sosedi(i, :);  
    
    
    celice_vozlisca = find(any(celice(:, 2:5) + 1 == i, 2));  

    ZL = 0; ZD = 0; SL = 0; SD = 0;

    for r = 1:numel(celice_vozlisca)

        v = celice(celice_vozlisca(r), 2:5) + 1;
        sredina_x = mean(x(v));
        sredina_y = mean(y(v));

        if sredina_x < x(i) && sredina_y > y(i)
            
            ZL = 1; 
        
        end    

        if sredina_x > x(i) && sredina_y > y(i)
            
            ZD = 1; 

        end  

        if sredina_x < x(i) && sredina_y < y(i)
            
            SL = 1; 
        end

        if sredina_x > x(i) && sredina_y < y(i)
            
            SD = 1; 
        
        end    

    end

    koef = [ZL + SL, ZD + SD, SL + SD, ZL + ZD]; 
    
    for q = 1:4

        if koef(q) > 0

            A(i, s(q)) = koef(q);

        end
    end

    switch celice_na_tocko(i)

        case 2  % rob: 2T + T + T - 2(Bi+2)T = -2 Bi T_inf

            A(i, i) = -2 * (Bi + 2);

        case 1  % zunanji kot:  T + T - 2(Bi+1)T = -2 Bi T_inf

            A(i, i) = -2 * (Bi + 1);

        case 3 % notranji kot: 2(T+T) + T + T - 2(Bi+3)T = -2 Bi T_inf

            A(i, i) = -2 * (Bi + 3);
    end

    b(i) = -2 * Bi * Tinf_vozlisca(i);

end

for g = 1:K
    id = rp(g).tocke + 1;
    if strcmp(rp(g).tip, 'toplotni tok')
        b(id) = -2 * rp(g).temperatura * dx / k;
    elseif strcmp(rp(g).tip, 'temperatura')
        for j = 1:numel(id)
            A(id(j), :) = 0;
            A(id(j), id(j)) = 1;
            b(id(j)) = rp(g).temperatura;
        end
    end
end

T = A \ b

A

b
%%

ime = 'lopatica_mreza';

[vrstice_A, stolpci_A, vrednosti_A] = find(A);
n = numel(vrednosti_A);

f = fopen([ime '_sistem.bin'], 'w', 'ieee-le');
fwrite(f, 'NROS', 'char');
fwrite(f, 1, 'int32');
fwrite(f, stevilo_vozlisc, 'int32');
fwrite(f, n, 'int32');
fwrite(f, vrstice_A - 1, 'int32');
fwrite(f, stolpci_A - 1, 'int32');
fwrite(f, vrednosti_A, 'double');
fwrite(f, b, 'double');
fclose(f);

%%

d = dir([ime '_sistem.bin']);
d.bytes
16 + 16 * n + 8 * stevilo_vozlisc

f = fopen([ime '_sistem.bin'], 'r', 'ieee-le');
id = fread(f, 4, '*char')';
ver = fread(f, 1, 'int32');
N = fread(f, 1, 'int32');
n2 = fread(f, 1, 'int32');
vrstice2 = fread(f, n2, 'int32');
stolpci2 = fread(f, n2, 'int32');
vrednosti2 = fread(f, n2, 'double');
b2 = fread(f, N, 'double');
fclose(f);
if ~strcmp(id, 'NROS'), error('Napacna datoteka'); end

A2 = sparse(vrstice2 + 1, stolpci2 + 1, vrednosti2, N, N);

razlika_A = full(max(max(abs(A2 - A))))
razlika_b = max(abs(b2 - b))

T2 = A2 \ b2;
razlika_T = max(abs(T2 - T))