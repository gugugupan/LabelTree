% function [ tree ] = initialize_tree( feature , label )
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
    tree.l = zeros( node_count , label_count ) ;
    tree.l( 1 , : ) = 1 ;
    
    % Train one-vs-all svm for each label
    disp( 'Train one-vs-all svm for each label' ) ;
    SVMs = cell( label_count , 1 ) ;
    PRODUCT = 10 ;
    LABMDA = 0.0001 ;
    for i = 1 : label_count 
        disp( [ 'Train one-vs-all SVM: ' , num2str( i ) ] ) ;
        positive = find( label == i ) ;
        negative = find( label ~= i ) ;
        negative_num = min( length( positive ) * PRODUCT , length( negative ) ) ;
        negative = negative( randperm( length( negative ) , negative_num ) ) ;
        list = [ positive ; negative ] ;
        temp_label_list = -1 * ones( length( list ) , 1 ) ;
        temp_label_list( 1 : length( positive ) ) = 1 ;
        temp_feature_list = feature( list , : ) ;
        weight = ones( length( list ) , 1 ) ;
        weight( 1 : length( positive ) ) = PRODUCT ;
        
        SVMs{ i } = struct() ;
        [ SVMs{ i }.w , SVMs{ i }.b , SVMs{ i }.info ] = ...
            vl_svmtrain( temp_feature_list' , temp_label_list' , LABMDA ) ;
    end

    % Test each one-vs-all svm by all feature
    disp( 'Calc confusion matrix' ) ;
    svm_test = zeros( feature_count , label_count ) ;
    for j = 1 : label_count
        disp( [ 'Calc for confusion matrix: [' , num2str(j) ,'/', num2str(label_count) ,']' ] ) ;
        esti = feature * SVMs{ j }.w + SVMs{ j }.b ;
        esti = ( esti - min( esti ) ) / ( max( esti ) - min( esti ) ) ;
        svm_test( : , j ) = esti ;
    end
%     save( 'svm_test.mat' , 'svm_test' ) ;

    % Calc confusion matrix C
    C = zeros( label_count , label_count ) ;
    for i = 1 : feature_count
        svm_test( i , : ) = svm_test( i , : ) / sum( svm_test( i , : ) ) ;
        C( label( i ) , : ) = C( label( i ) , : ) + svm_test( i , : ) ;
    end
    for j = 1 : label_count
        C( j , : ) = C( j , : ) / sum( label == j ) ;
    end
    C = ( C + C' ) / 2 ;

    node_counter = 1 ;
    for i = 1 : node_count
        disp( [ 'Learning Tree Structure... ' , num2str( i ) , '/' , num2str( node_count ) ] ) ;
        
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
%         map_node_label = zeros( label_count , 1 ) ;
%         map_node_label( node_label ) = 1 : node_label_count ;
%         node_feature_id_list = find( ismember( label , node_label ) ) ;
%         node_feature_count = length( node_feature_id_list ) ;
%         node_feature_label = map_node_label(label(node_feature_id_list)) ;
%         node_feature = feature( node_feature_id_list , : ) ;
        
        CC = C( node_label , node_label ) ;
        
        % And using spectral clustering
        label_split = spectral_clustering( CC + 1e-6 , 2 ) ;
%         disp( label_split ) ;
        
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
% end