function measure=similarity_measure(vec_1,vec_2)
  vec_1_size = size(vec_1);
  vec_2_size = size(vec_2);

  dot_product = dot(vec_1,vec_2);

  enumerator = sqrt(dot_product);

  measure = dot_product/enumerator;
endfunction