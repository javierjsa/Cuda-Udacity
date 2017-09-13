// Homework 1
// Color to Greyscale Conversion

//A common way to represent color images is known as RGBA - the color
//is specified by how much Red, Green, and Blue is in it.
//The 'A' stands for Alpha and is used for transparency; it will be
//ignored in this homework.

//Each channel Red, Blue, Green, and Alpha is represented by one byte.
//Since we are using one byte for each color there are 256 different
//possible values for each color.  This means we use 4 bytes per pixel.

//Greyscale images are represented by a single intensity value per pixel
//which is one byte in size.

//To convert an image from color to grayscale one simple method is to
//set the intensity to the average of the RGB channels.  But we will
//use a more sophisticated method that takes into account how the eye 
//perceives color and weights the channels unequally.

//The eye responds most strongly to green followed by red and then blue.
//The NTSC (National Television System Committee) recommends the following
//formula for color to greyscale conversion:

//I = .299f * R + .587f * G + .114f * B

//Notice the trailing f's on the numbers which indicate that they are 
//single precision floating point constants and not double precision
//constants.

//You should fill in the kernel as well as set the block and grid sizes
//so that the entire image is processed.

#include "reference_calc.cpp"
#include "utils.h"
#include <stdio.h>
#include <iostream>

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  //TODO
  //Fill in the kernel to convert from color to greyscale
  //the mapping from components of a uchar4 to RGBA is:
  // .x -> R ; .y -> G ; .z -> B ; .w -> A
  //
  //The output (greyImage) at each pixel should be the result of
  //applying the formula: output = .299f * R + .587f * G + .114f * B;
  //Note: We will be ignoring the alpha channel for this conversion

  //First create a mapping from the 2D block and grid locations
  //to an absolute 2D location in the image, then use that to
  //calculate a 1D offset
  //blockDim.x*blockIdx.x + threadIdx.x


  int block_start_row = blockIdx.y * numCols * blockDim.y;
  int block_start_col = blockIdx.x * blockDim.x;
 
  int thread_row = block_start_row + threadIdx.y * numCols;
  int thread_col = block_start_col + threadIdx.x;
  
  int thread_pos = thread_row+thread_col;
  
  if (thread_pos<numRows*numCols){
  
     uchar4 rgba = rgbaImage[thread_pos];
     float channelSum = .299f * rgba.x + .587f * rgba.y + .114f * rgba.z;
     greyImage[thread_pos] = channelSum;  
  }     

}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  //You must fill in the correct sizes for the blockSize and gridSize
  //currently only one block with one thread is being launched
  
  const int block_size = 32;
  
  int block_rows, block_cols;

  if (numRows % block_size >0) 
     block_rows = (numRows/block_size)+ 1;
  else
     block_rows = (numRows/block_size);

  if (numCols % block_size >0) 
     block_cols = int(numCols/block_size)+ 1;
  else
     block_cols = int(numCols/32);
 
  //std::cout<<"Rows: "<<block_rows<<" Cols: "<< block_cols<<"\n";
  //std::cout<<"numRows: "<<numRows<<" numCols: "<< numCols;
  
  //Allocate memory
  const dim3 blockSize(block_size,block_size, 1);  //TODO
  const dim3 gridSize( block_cols, block_rows, 1);  //TODO
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());
}

