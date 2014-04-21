
clear ;
load( 'toy_data.mat' ) ;

tree = initialize_tree( feature , label ) ;
tree.w = gradient_descent( tree ) ;
