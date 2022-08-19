%*******************************************************************************
% Función:   [varargout] = op_aux_equalize_dimensions(expand_empty,varargin)
%
% Propósito: Ajusta las dimensiones de los datos numéricos de entrada
%
% Entrada:   - expand_empty: Identificador para expandir o no las matrices
%              vacías. Dos posibilidades:
%              - 0: Las matrices de entrada vacías son devueltas de igual modo
%              - Distinto de 0: Las matrices de entrada vacía se redimensionan
%                en la salida y se rellenan de ceros
%            - Resto de argumentos de entrada
%
% Salida:    - Tantos argumentos como argumentos de entrada se hayan pasado
%              (sin contar 'expand_empty')
%
% Nota: Los datos de entrada no numéricos se devuelven como hayan sido pasados
%
% Historia:  22-02-2020: Creación de la función
%                        José Luis García Pallero, jgpallero@gmail.com
%*******************************************************************************

function [varargout] = op_aux_equalize_dimensions(expand_empty,varargin)

if nargin<2
    %Salimos con argumento vacío
    varargout{1} = [];
else
    %Número de elementos de trabajo
    nElem = length(varargin);
    %Número máximo de filas y columnas
    maxFil = 0;
    maxCol = 0;
    %Posición del elemento de dimensiones mayores
    posMax = 0;
    %Tipo de los elementos de trabajo
    numero = ones(1,nElem);
    %Recorremos los elementos de entrada de trabajo
    for i=1:nElem
        %Comprobamos si el tipo de dato es numérico
        if isnumeric(varargin{i})
            %Extraigo sus dimensiones
            [fil,col] = size(varargin{i});
            %Compruebo si el objeto es el mayor
            if (fil>maxFil)||(col>maxCol)
                maxFil = fil;
                maxCol = col;
                posMax = i;
            end
        else
            %Indico que el dato no es numérico
            numero(i) = 0;
        end
    end
    %Recorremos de nuevo los elementos
    for i=1:nElem
        %Compruebo el tipo de dato
        if ~numero(i)
            %Si el dato no es numérico lo devuelvo como está
            varargout{i} = varargin{i};
        elseif i~=posMax
            %Compruebo si el elemento está vacío
            if isempty(varargin{i})&&(expand_empty==0)
                %Asigno el mismo elemento de entrada
                varargout{i} = varargin{i};
            elseif isempty(varargin{i})&&(expand_empty~=0)
                %Creo una matriz de ceros
                varargout{i} = zeros(maxFil,maxCol);
            else
                %Voy comprobando dimensiones
                if isscalar(varargin{i})
                    %Copio el elemento con las dimensiones máximas
                    varargout{i} = ones(maxFil,maxCol)*varargin{i};
                elseif isrow(varargin{i})
                    %Compruebo si las dimensiones son congruentes
                    if size(varargin{i},2)~=maxCol
                        %Emito el mensaje de error
                        error(['The dimensions of input arguments are not ',...
                               'congruent']);
                    else
                        %Redimensiono el elemento
                        varargout{i} = repmat(varargin{i},maxFil,1);
                    end
                elseif iscolumn(varargin{i})
                    %Compruebo si las dimensiones son congruentes
                    if size(varargin{i},1)~=maxFil
                        %Emito el mensaje de error
                        error(['The dimensions of input arguments are not ',...
                               'congruent']);
                    else
                        %Redimensiono el elemento
                        varargout{i} = repmat(varargin{i},1,maxCol);
                    end
                else
                    %Compruebo si las dimensiones son congruentes
                    if (size(varargin{i},1)~=maxFil)||...
                       (size(varargin{i},2)~=maxCol)
                        %Emito el mensaje de error
                        error(['The dimensions of input arguments are not ',...
                               'congruent']);
                    else
                        %Copio el elemento en la salida
                        varargout{i} = varargin{i};
                    end
                end
            end
        else
            %Copio en la salida el elemento de dimensiones máximas
            varargout{i} = varargin{i};
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright (c) 2020, J.L.G. Pallero. All rights reserved.
%
%Redistribution and use in source and binary forms, with or without
%modification, are permitted provided that the following conditions are met:
%
%- Redistributions of source code must retain the above copyright notice, this
%  list of conditions and the following disclaimer.
%- Redistributions in binary form must reproduce the above copyright notice,
%  this list of conditions and the following disclaimer in the documentation
%  and/or other materials provided with the distribution.
%- Neither the name of the copyright holders nor the names of its contributors
%  may be used to endorse or promote products derived from this software without
%  specific prior written permission.
%
%THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY DIRECT,
%INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
%BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
%DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
%LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
%OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
%ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
