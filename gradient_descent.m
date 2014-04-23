function [ w  , b ] = gradient_descent( feature , label , tree )
% ���ݴ�������ṹ�����ݶ��½���ѵ�����������ѵ���õ��ľ���
% �ݶ��½�ʹ������ݶ��½��������ѡ��һ��������Ϊ��������
% 
% Input
%       feature[N*D] - N feature vector with D dimension
%       label[N*1] - Label vector with N rows
%       tree[struct] - Label Tree structure
%
% Output
%       w[M*D] - M parameters vector for each tree node
%                (M is node count)
%
    gamma = 0.00001 ;

    w = zeros( tree.node_count , tree.feature_dimension ) ;
    b = zeros( tree.node_count , 1 ) ;
    [ n , d ] = size( feature ) ;
    if ( d ~= tree.feature_dimension )
        error( 'vector demension not matching' ) ;
    end
    
    % Start Iteration
    for iter = 1 : 65536
        sample_index = randperm( n , 1 ) ;
        sample_feature = feature( sample_index , : ) ;
        sample_label = label( sample_index ) ;
        
        % Finding r,s
        r = -1 ;
        s = -1 ;
        max_delta = 0 ;
        path = find( tree.l( : , sample_label ) ) ;
        for i = 1 : length( path )
            child = find( tree.father == path( i ) ) ;
            if ( isempty( child )  )
                continue ;
            end
            true_child = child( ismember( child , path ) ) ;
            for j = 1 : length( child )
                if ( child( j ) ~= true_child )
                    delta = w( child( j ) , : ) * sample_feature' - ...
                            w( true_child , : ) * sample_feature' + ... 
                            + b( child( j ) ) - b( true_child ) ;
                    if ( delta >= max_delta )
                        max_delta = delta ;
                        r = true_child ;
                        s = child( j ) ;
                    end
                end
            end
        end
        
        % descent for every vector
        for i = 1 : tree.node_count 
            w( i , : ) = w( i , : ) - 2 * gamma * w( i , : ) ;
        end
        
        % descent for r,s 
        if ( r ~= -1 && s ~= -1 )
            w( r , : ) = w( r , : ) + sample_feature / n ;
            w( s , : ) = w( s , : ) - sample_feature / n ;
            b( r ) = b( r ) + 1 / n ;
            b( s ) = b( s ) - 1 / n ;
        end
    end
end
