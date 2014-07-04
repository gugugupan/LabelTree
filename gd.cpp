/*
 * Gradient Descent for Label Tree - Matlab Mex
 *
 * Usage :
 *     [ w , b ] = gd( feature , label , father , L , ?eta , ?gamma , ?iter_num )
 *
 * Input :
 *     feature[feature*dimension] : feature matrix for training data
 *     label[feature*1] : label vector for training data
 *     father[node*1] : tree struct vector (father[0] == -1)
 *     L[node*label] : label set for each node
 *     eta : learning rate (default 0.1)
 *     gamma : step width (default 0.001)
 *     iter_num : number of iteration (default 5)
 */

#include <cmath>
#include <algorithm>
#include <queue>
#include "mex.h"
using namespace std;

#define sqr(x) ((x)*(x))
#define INF 1000000

class MatDoubleMatrix {
private :
	int n , m ; // N * M matrix
	double *ptr ; // matrix pointer
	
public :
	MatDoubleMatrix( int n , int m , double *ptr )
	{
		this -> n = n ;
		this -> m = m ;
		this -> ptr = ptr ;
	}
	
	int set( int i , int j , double val ) 
	{
		if ( i < 0 || j < 0 || i >= n || j >= m ) 
			return -1 ;
		ptr[ n * j + i ] = val ;
		return 0 ;
	}
	
	double get( int i , int j )
	{
		return ( double ) ptr[ n * j + i ] ;
	}
} ;

void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray*prhs[] )
{
    double eta , gamma ;
    int iter_num ;
	/* ===================== Input Checker ======================== */
	if ( nrhs < 4 )
		mexErrMsgTxt( "Incorrect number of input arguments." ) ;
	if ( mxGetM( prhs[ 0 ] ) != mxGetM( prhs[ 1 ] ) )
		mexErrMsgTxt( "Dimension of two matrix differs." ) ;
    if ( (int) mxGetM( prhs[ 1 ] ) != 1 )
        mexErrMsgTxt( "\'label\' is not vector." ) ;
    if ( (int) mxGetM( prhs[ 2 ] ) != 1 )
        mexErrMsgTxt( "\'father\' is not vector." ) ;
    if ( (int) mxGetN( prhs[ 1 ] ) != (int) mxGetM( prhs[ 3 ] ) || 
            (int) mxGetN( prhs[ 2 ] ) != (int) mxGetN( prhs[ 3 ] ) )
        mexErrMsgTxt( "Incorrect of \'L\'s dimension" ) ;
    if ( nrhs >= 5 )
        eta = (double) *mxGetPr( prhs[ 5 ] ) ;
    else
        eta = 0.1 ;
    if ( nrhs >= 6 )
        gamma = (double) *mxGetPr( prhs[ 6 ] ) ;
    else
        gamma = 0.001 ;
    if ( nrhs >= 7 )
        iter_num = (int) *mxGetPr( prhs[ 7 ] ) ;
    else
        iter_num = 5 ;
	
	/* ===================== Input Labels ========================= */
    /* [ w , b ] = gd( feature , label , father , L ) */
    int feature_count = (int) GetN( prhs[ 0 ] ) ;
    int dimension = (int) GetM( prhs[ 0 ] ) ;
    int label_count = (int) GetN( prhs[ 1 ] ) ;
    int node_count = (int) GetN( prhs[ 2 ] ) ;
    
    MatDoubleMatrix feature = MatDoubleMatrix( feature_count , dimension , (double *) mxGetPr( prhs[ 0 ] ) ) ;
    MatDoubleMatrix label   = MatDoubleMatrix( label_count , 1 , (double *) MatDoubleMatrix ) ;
    
	/* ===================== Output Labels ======================== */
	nlhs = 1 ;
	plhs[ 0 ] = mxCreateDoubleMatrix( k , n , mxREAL ) ;
	MatDoubleMatrix I = MatDoubleMatrix( k , n , ( double * ) mxGetPr( plhs[ 0 ] ) ) ;
	
	/* ===================== Calc ======================== */
// 	dist = ( double * ) mxMalloc( sizeof( double ) * m ) ;
// 	place = ( int * ) mxMalloc( sizeof( int ) * m ) ;
// 	mxFree( dist ) ;
// 	mxFree( place ) ;
}
