% function [ w ] = gradient_descent( feature , label , tree )
% 根据传入的树结构进行梯度下降的训练，返回最后训练得到的矩阵
% 梯度下降使用随机梯度下降：即随机选择一个样本作为测试样本
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
    gamma = 0.001 ;

    w = zeros( tree.node_count , tree.feature_dimension ) ;
    [ n , d ] = size( feature ) ;
    
    % Start Iteration
    for iter = 1 : 65536
        sample_index = randperm( n , 1 ) ;
        sample_feature = feature( sample_index , : ) ;
        sample_label = label( sample_index ) ;
        
        % Finding r,s
        r = -1 ;
        s = -1 ;
        min_delta = -1 ;
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
                            w( true_child , : ) * sample_feature' ;
                    if ( min_delta == -1 || delta < min_delta )
                        min_delta = delta ;
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
        w( r , : ) = w( r , : ) + sample_feature / n ;
        w( s , : ) = w( s , : ) - sample_feature / n ;
    end
% end
