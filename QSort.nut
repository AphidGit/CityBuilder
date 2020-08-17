// QUICKSORT ALGORITHM.

// THIS FILE IS PUBLIC DOMAIN

function QSort(index, array);
	/**
	 * Sort the array array with the index index.
	 * @param index The values used to sort. 
	 * Define operator <=!
	 * @param array The array that gets sorted.
	 * @return The sorted array
	 */
	 
function QSort(index, array){
// pedantic cases
local l = index.len();
if(l == 1){return array;}
else if(l == 0){return [];}
else if(l == 2){
    if(index[0] <= index[1]) {
        return array;
    } else {
        local a = [array[1], array[0]];
        return a;
    }    
}
// initialize 
local pivot = index[l / 2];
local index_lh = [];
local index_rh = [];
local array_lh = [];
local array_rh = [];
local pivots = [];
// compare and place in two halves
for(local i = 0; i < index.len(); i++)
	{
	if(index[i] < pivot)
		{
index_lh.append(index[i]);
array_lh.append(array[i]);
		}
	else if(index[i] > pivot){
index_rh.append(index[i]);
array_rh.append(array[i]);
		} else {
			pivots.append(array[i]);
		}
	}
// Sort the two halves.
local a = [];
a.extend(QSort(index_lh, array_lh));
a.extend(pivots);
a.extend(QSort(index_rh, array_rh));
return a;
}

function QSort_R(index, array){
// pedantic cases
local l = index.len();
if(l == 1){return array;}
else if(l == 0){return [];}
else if(l == 2){
    if(index[0] >= index[1]) {
        return array;
    } else {
        local a = [array[1], array[0]];
        return a;
    }    
}
// initialize 
local pivot = index[l / 2];
local index_lh = [];
local index_rh = [];
local array_lh = [];
local array_rh = [];
local pivots = [];
// compare and place in two halves
for(local i = 0; i < index.len(); i++)
	{
	if(index[i] > pivot)
		{
index_lh.append(index[i]);
array_lh.append(array[i]);
		}
	else if(index[i] < pivot){
index_rh.append(index[i]);
array_rh.append(array[i]);
		} else {
			pivots.append(array[i]);
		}
	}
// Sort the two halves.
local a = [];
a.extend(QSort(index_lh, array_lh));
a.extend(pivots);
a.extend(QSort(index_rh, array_rh));
return a;
}

