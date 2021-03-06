function e = circular_buffer(v, N_ref, I_LBRM, rv_idx, E)
% CIRCULAR_BUFFER performs circular buffering, as specified in Section
% 5.1.4.1.2 of TS36.212.
%   e = CIRCULAR_BUFFER(v, N_ref, I_LBRM, rv_idx, E) circular buffers
%   interleaves a specified bit matrix, using various specified parameters.
%
%   v should be a matrix comprising 3 rows and K_Pi columns, filler bits to
%   be punctured should be indicated by NaN-valued elements.
%
%   N_ref should be set to floor(N_IR/C), as described in Section 5.1.4.1.2
%   of TS36.212.
%
%   I_LBRM should be set to 0 for UL-SCH, MCH, SL-SCH and SL-DCH transport
%   channels, as well as for UE category 0 for DL-SCH associated with
%   SI-RNTI and RA-RNTI and PCH transport channel. Otherwise, I_LBRM should
%   be set to a value other than 0 for DL-SCH and PCH transport channels,
%   as described in Section 5.1.4.1.2 of TS36.212.
%
%   rv_idx specifies the redundancy version, which should be selected from
%   the set 0, 1, 2 or 3, as described in Section 5.1.4.1.2 of TS36.212.
%   
%   E specifies the encoded block length.
%   
%   e will be a row vector of length E.
%
% Copyright � 2018 Robert G. Maunder. This program is free software: you
% can redistribute it and/or modify it under the terms of the GNU General
% Public License as published by the Free Software Foundation, either
% version 3 of the License, or (at your option) any later version. This
% program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
% more details.




C_TC_subblock = 32;
K_Pi = size(v,2);

if mod(K_Pi,32) ~= 0
    error('K_Pi should be a multiple of 32.');
end

R_TC_subblock = K_Pi/C_TC_subblock;

if size(v,1) ~= 3
    error('v should have three rows.');
end
if rv_idx < 0 || rv_idx > 3
    error('Unsupported rv_id');
end

K_w = 3*K_Pi;

w = zeros(1,K_w);

for k=0:K_Pi-1
    w(k+1) = v(1,k+1);
end
for k=0:K_Pi-1
    w(K_Pi+2*k+1) = v(2,k+1);
end
for k=0:K_Pi-1
    w(K_Pi+2*k+2) = v(3,k+1);
end

if I_LBRM == 0
    N_cb = K_w;
else
    N_cb = min(N_ref, K_w);
end

k_0 = R_TC_subblock*(2*ceil(N_cb/(8*R_TC_subblock))*rv_idx+2);

e = zeros(1,E);

k=0;
j=0;
while k < E
    if ~isnan(w(mod(k_0+j,N_cb)+1))
        e(k+1) = w(mod(k_0+j,N_cb)+1);
        k=k+1;
    end
    j=j+1;
end


