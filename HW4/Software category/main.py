from PIL import Image
import numpy as np
import math

def float_to_binary(decimal):
    #integer to binary
    integer_binary = format(int(decimal), 'b').zfill(9)
    #float to binary
    fraction = decimal - int(decimal)
    binary_fraction = ''
    for i in range(4):
        fraction *= 2
        if fraction >= 1:
            binary_fraction += '1'
            fraction -= 1
        else:
            binary_fraction += '0'
    binary = integer_binary + binary_fraction
    return binary

#read data use image.png or image.jpg
extension = ".png"
image = Image.open("./image"+extension)
image_gray = image.convert('L')

#resize image to 64x64
image_gray = image_gray.resize((64,64))
#pillow image to numpy array
image_array = np.array(image_gray)


#write img.dat
annotation = " //data "
imline = image_array.flatten()
with open("./img.dat","w") as file:
    for i in range(4096):
        file.write(format(imline[i],'b').zfill(9).ljust(13,'0')+annotation+str(i)+": "+str(round(float(imline[i]),1))+"\n")
print(image_array.shape)

#layer 0
dilation = 2

layer0 = np.pad(image_gray,((dilation,dilation),(dilation,dilation)),'edge')
kernel = np.array([[-0.0625,0,-0.125,0,-0.0625],
                  [0,0,0,0,0],
                  [-0.25,0,1,0,-0.25],
                  [0,0,0,0,0],
                  [-0.0625,0,-0.125,0,-0.0625]],dtype=np.float32)
L1arr = []
bias = -0.75
for i in range(64):
    for j in range(64):
        L1arr.append(np.sum(layer0[i:i+5,j:j+5]*kernel)+bias)
L1arr = [ max(0, data) for data in np.array(L1arr)]
L2arr = np.array(L1arr).reshape(64,64)
with open("./layer0_golden.dat","w") as file:
    for i in range(4096):
        file.write(float_to_binary(L1arr[i])+annotation+str(i)+": "+str(round(float(L1arr[i]),4))+"\n")

#layer 1
pooling_size = 2
output_feature_map = np.zeros((32, 32))
for i in range(32):
    for j in range(32):
        row_start = i * pooling_size
        col_start = j * pooling_size
        submatrix = L2arr[row_start:row_start+pooling_size, col_start:col_start+pooling_size]
        output_feature_map[i, j] = np.max(submatrix)
output_feature_map = output_feature_map.flatten()
with open("./layer1_golden.dat","w") as file:
    for i in range(1024):
        file.write(float_to_binary(math.ceil(output_feature_map[i]))+annotation+str(i)+": "+str(round(float(math.ceil(output_feature_map[i])),1))+"\n")