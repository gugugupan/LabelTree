function [ tree ] = initialize_tree( feature , label )
% 根据传入的图像特征以及图像标签，生成一颗已经确定结构的 Label Tree
% 传入参数
%       feature[N*D] - N个特征向量，每一个特征向量为D维
%       label[N*1] - N个标签
% 传出参数
%       tree[struct] - 训练得到的 Label Tree 结构
% 

    [ feature_count , dimension ] = size( feature ) ;
    label_count = max( label ) ;
    node_count = label_count * 2 - 1 ;
    
    tree = struct() ;
    tree.label_count = label_count ;
    tree.feature_dimension = dimension ;
    tree.child = zeros( node_count , 2 ) ;
    % predictor parameter matrix w
    tree.w = zeros( node_count , dimension ) ;
    % label set for each node
    tree.l = zeros( node_count , label_count ) ;
    tree.l( 1 , : ) = 1 ;
    
    for i = 1 : node_count
        % Initialize for each node
        node_label_count = sum( tree.l( i , : ) ) ;
        node_label = find( tree.l( i , : ) ) ;
        if ( node_label_count == 1 )
            continue ;
        end
        node_feature_id_list = find( ismember( label , node_label ) ) ;
        node_feature_count = length( node_feature_id_list ) ;
        node_feature_label = label( node_feature_id_list ) ;
        node_feature = feature( node_feature_id_list , : ) ;
        
        % Train one-vs-all svm for each label
        SVMs = cell( node_label_count , 1 ) ;
        for j = 1 : node_label_count 
            temp_label_list = -1 * ones( node_feature_count , 1 ) ;
            temp_label_list( ismember( node_feature_label , j ) ) = 1 ;
            SVMs{ j } = svmtrain( node_feature , temp_label_list ) ;
        end
        
        % Test each one-vs-all svm by all feature
        svm_test = zeros( node_label_count , node_feature_count ) ;
        for j = 1 : node_label_count
            svm_test( j , : ) = svmpredict( SVMs{ j } , node_feature , ones( node_feature_count , 1 ) ) ;
        end
        
        % Calc confusion matrix C
        C = zeros( node_label_count , node_label_count ) ;
        
        %
    end
end
