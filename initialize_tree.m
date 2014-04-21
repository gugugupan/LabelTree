function [ tree ] = initialize_tree( feature , label )
% 根据传入的图像特征以及图像标签，生成一颗已经确定结构的 Label Tree
% 默认 Label Tree 是一个二叉树
%
% Input
%       feature[N*D] - N feature vector with D dimension
%       label[N*1] - A label vector with N rows
%
% Output
%       tree[struct] - Label Tree structure
% 
    [ feature_count , dimension ] = size( feature ) ;
    label_count = max( label ) ;
    node_count = label_count * 2 - 1 ;
    
    tree = struct() ;
    tree.label_count = label_count ;
    tree.node_count = node_count ;
    tree.feature_dimension = dimension ;
    tree.child = zeros( node_count , 2 ) ;
    tree.father = zeros( node_count , 1 ) ;
    % predictor parameter matrix w
    tree.w = zeros( node_count , dimension ) ;
    % label set for each node
    tree.l = zeros( node_count , label_count ) ;
    tree.l( 1 , : ) = 1 ;
    
    node_counter = 1 ;
    for i = 1 : node_count
        disp( [ 'Building Tree Structure... ' , num2str( i ) , '/' , num2str( node_count ) ] ) ;
        
        % Initialize for each node
        node_label_count = sum( tree.l( i , : ) ) ;
        node_label = find( tree.l( i , : ) ) ;
        if ( node_label_count == 1 )
            continue ;
        end
        % Mapping label(num) to node_label(num)
        %    label(num) is 1:label_count
        %    node_label(num) is 1:node_label_count
        %    so there need a mapping
        %  
        %    node_label : node_label(num) -> label(num)
        %    map_node_label : label(num) -> node_label(num)
        map_node_label = zeros( label_count , 1 ) ;
        map_node_label( node_label ) = 1 : node_label_count ;
        node_feature_id_list = find( ismember( label , node_label ) ) ;
        node_feature_count = length( node_feature_id_list ) ;
        node_feature_label = map_node_label( label( node_feature_id_list ) ) ;
        node_feature = feature( node_feature_id_list , : ) ;
        
        % Train one-vs-all svm for each label
        SVMs = cell( node_label_count , 1 ) ;
        for j = 1 : node_label_count 
            temp_label_list = -1 * ones( node_feature_count , 1 ) ;
            temp_label_list( ismember( node_feature_label , j ) ) = 1 ;
            SVMs{ j } = svmtrain( temp_label_list , node_feature , '-b 1 -q' ) ;
        end

        % Test each one-vs-all svm by all feature
        svm_test = zeros( node_feature_count , node_label_count ) ;
        for j = 1 : node_label_count
            [ ~ , ~ , esti ] = svmpredict( ones( node_feature_count , 1 ) , node_feature , SVMs{ j } , '-b 1 -q' ) ;
            svm_test( : , j ) = esti( : , 1 ) ;
        end
        [ ~ , svm_test_label ] = max( svm_test , [] , 2 ) ;

        % Calc confusion matrix C
        C = zeros( node_label_count , node_label_count ) ;
        for j = 1 : node_feature_count
            C( node_feature_label( j ) , svm_test_label( j ) ) = ...
                C( node_feature_label( j ) , svm_test_label( j ) ) + 1 ;
        end
        C = ( C + C' ) / 2 ;
        
        % And using spectral clustering
        label_split = spectral_clustering( C + 1e-6 , 2 ) ;
        
        % Split label to two child node
        for j = 1 : 2 
            node_counter = node_counter + 1 ;
            tree.child( i , j ) = node_counter ;
            tree.father( node_counter ) = i ;
            % There need a re-map
            %    node_label -> label
            % tree.l( node_counter , label_split == j ) = 1 ;
            tree.l( node_counter , node_label( label_split == j ) ) = 1 ;
        end
      
    end
end
