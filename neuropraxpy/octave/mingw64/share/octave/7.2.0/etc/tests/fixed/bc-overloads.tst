## !!! DO NOT EDIT !!!
## THIS IS AN AUTOMATICALLY GENERATED FILE
## modify build-bc-overload-tests.sh to generate the tests you need.

%!shared ex
%! ex.double = 1;
%! ex.single = single (1);
%! ex.logical = true;
%! ex.char = 'char';
%! ex.int8  = int8 (1);
%! ex.int16 = int16 (1);
%! ex.int32 = int32 (1);
%! ex.int64 = int64 (1);
%! ex.uint8  = uint8 (1);
%! ex.uint16 = uint16 (1);
%! ex.uint32 = uint32 (1);
%! ex.uint64 = uint64 (1);
%! ex.cell = {};
%! ex.struct = struct ();
%! ex.function_handle = @numel;

%% Name call
%!assert (tbcover (ex.double, ex.double), "double")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.double), "double")

%% Name call
%!assert (tbcover (ex.double, ex.single), "single")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.single), "single")

%% Name call
%!assert (tbcover (ex.double, ex.logical), "double")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.logical), "double")

%% Name call
%!assert (tbcover (ex.double, ex.char), "double")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.char), "double")

%% Name call
%!assert (tbcover (ex.double, ex.int8), "int8")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.int8), "int8")

%% Name call
%!assert (tbcover (ex.double, ex.int16), "int16")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.int16), "int16")

%% Name call
%!assert (tbcover (ex.double, ex.int32), "int32")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.int32), "int32")

%% Name call
%!assert (tbcover (ex.double, ex.int64), "int64")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.int64), "int64")

%% Name call
%!assert (tbcover (ex.double, ex.uint8), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.uint8), "uint8")

%% Name call
%!assert (tbcover (ex.double, ex.uint16), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.uint16), "uint16")

%% Name call
%!assert (tbcover (ex.double, ex.uint32), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.uint32), "uint32")

%% Name call
%!assert (tbcover (ex.double, ex.uint64), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.uint64), "uint64")

%% Name call
%!assert (tbcover (ex.double, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.double, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.double, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.double, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.single, ex.double), "single")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.double), "single")

%% Name call
%!assert (tbcover (ex.single, ex.single), "single")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.single), "single")

%% Name call
%!assert (tbcover (ex.single, ex.logical), "single")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.logical), "single")

%% Name call
%!assert (tbcover (ex.single, ex.char), "single")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.char), "single")

%% Name call
%!assert (tbcover (ex.single, ex.int8), "int8")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.int8), "int8")

%% Name call
%!assert (tbcover (ex.single, ex.int16), "int16")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.int16), "int16")

%% Name call
%!assert (tbcover (ex.single, ex.int32), "int32")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.int32), "int32")

%% Name call
%!assert (tbcover (ex.single, ex.int64), "int64")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.int64), "int64")

%% Name call
%!assert (tbcover (ex.single, ex.uint8), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.uint8), "uint8")

%% Name call
%!assert (tbcover (ex.single, ex.uint16), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.uint16), "uint16")

%% Name call
%!assert (tbcover (ex.single, ex.uint32), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.uint32), "uint32")

%% Name call
%!assert (tbcover (ex.single, ex.uint64), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.uint64), "uint64")

%% Name call
%!assert (tbcover (ex.single, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.single, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.single, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.single, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.logical, ex.double), "double")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.double), "double")

%% Name call
%!assert (tbcover (ex.logical, ex.single), "single")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.single), "single")

%% Name call
%!assert (tbcover (ex.logical, ex.logical), "logical")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.logical), "logical")

%% Name call
%!assert (tbcover (ex.logical, ex.char), "char")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.char), "char")

%% Name call
%!assert (tbcover (ex.logical, ex.int8), "int8")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.int8), "int8")

%% Name call
%!assert (tbcover (ex.logical, ex.int16), "int16")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.int16), "int16")

%% Name call
%!assert (tbcover (ex.logical, ex.int32), "int32")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.int32), "int32")

%% Name call
%!assert (tbcover (ex.logical, ex.int64), "int64")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.int64), "int64")

%% Name call
%!assert (tbcover (ex.logical, ex.uint8), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.uint8), "uint8")

%% Name call
%!assert (tbcover (ex.logical, ex.uint16), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.uint16), "uint16")

%% Name call
%!assert (tbcover (ex.logical, ex.uint32), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.uint32), "uint32")

%% Name call
%!assert (tbcover (ex.logical, ex.uint64), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.uint64), "uint64")

%% Name call
%!assert (tbcover (ex.logical, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.logical, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.logical, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.logical, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.char, ex.double), "char")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.double), "char")

%% Name call
%!assert (tbcover (ex.char, ex.single), "single")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.single), "single")

%% Name call
%!assert (tbcover (ex.char, ex.logical), "char")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.logical), "char")

%% Name call
%!assert (tbcover (ex.char, ex.char), "char")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.char), "char")

%% Name call
%!assert (tbcover (ex.char, ex.int8), "int8")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.int8), "int8")

%% Name call
%!assert (tbcover (ex.char, ex.int16), "int16")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.int16), "int16")

%% Name call
%!assert (tbcover (ex.char, ex.int32), "int32")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.int32), "int32")

%% Name call
%!assert (tbcover (ex.char, ex.int64), "int64")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.int64), "int64")

%% Name call
%!assert (tbcover (ex.char, ex.uint8), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.uint8), "uint8")

%% Name call
%!assert (tbcover (ex.char, ex.uint16), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.uint16), "uint16")

%% Name call
%!assert (tbcover (ex.char, ex.uint32), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.uint32), "uint32")

%% Name call
%!assert (tbcover (ex.char, ex.uint64), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.uint64), "uint64")

%% Name call
%!assert (tbcover (ex.char, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.char, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.char, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.char, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.int8, ex.double), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.double), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.single), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.single), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.logical), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.logical), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.char), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.char), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.int8), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.int8), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.int16), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.int16), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.int32), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.int32), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.int64), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.int64), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.uint8), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.uint8), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.uint16), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.uint16), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.uint32), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.uint32), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.uint64), "int8")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.uint64), "int8")

%% Name call
%!assert (tbcover (ex.int8, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.int8, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.int8, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.int8, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.int16, ex.double), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.double), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.single), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.single), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.logical), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.logical), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.char), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.char), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.int8), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.int8), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.int16), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.int16), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.int32), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.int32), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.int64), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.int64), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.uint8), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.uint8), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.uint16), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.uint16), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.uint32), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.uint32), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.uint64), "int16")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.uint64), "int16")

%% Name call
%!assert (tbcover (ex.int16, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.int16, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.int16, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.int16, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.int32, ex.double), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.double), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.single), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.single), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.logical), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.logical), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.char), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.char), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.int8), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.int8), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.int16), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.int16), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.int32), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.int32), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.int64), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.int64), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.uint8), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.uint8), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.uint16), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.uint16), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.uint32), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.uint32), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.uint64), "int32")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.uint64), "int32")

%% Name call
%!assert (tbcover (ex.int32, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.int32, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.int32, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.int32, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.int64, ex.double), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.double), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.single), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.single), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.logical), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.logical), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.char), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.char), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.int8), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.int8), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.int16), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.int16), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.int32), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.int32), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.int64), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.int64), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.uint8), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.uint8), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.uint16), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.uint16), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.uint32), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.uint32), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.uint64), "int64")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.uint64), "int64")

%% Name call
%!assert (tbcover (ex.int64, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.int64, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.int64, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.int64, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.uint8, ex.double), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.double), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.single), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.single), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.logical), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.logical), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.char), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.char), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.int8), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.int8), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.int16), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.int16), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.int32), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.int32), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.int64), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.int64), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.uint8), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.uint8), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.uint16), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.uint16), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.uint32), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.uint32), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.uint64), "uint8")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.uint64), "uint8")

%% Name call
%!assert (tbcover (ex.uint8, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.uint8, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.uint8, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.uint8, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.uint16, ex.double), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.double), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.single), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.single), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.logical), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.logical), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.char), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.char), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.int8), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.int8), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.int16), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.int16), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.int32), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.int32), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.int64), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.int64), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.uint8), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.uint8), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.uint16), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.uint16), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.uint32), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.uint32), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.uint64), "uint16")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.uint64), "uint16")

%% Name call
%!assert (tbcover (ex.uint16, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.uint16, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.uint16, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.uint16, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.uint32, ex.double), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.double), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.single), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.single), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.logical), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.logical), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.char), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.char), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.int8), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.int8), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.int16), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.int16), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.int32), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.int32), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.int64), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.int64), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.uint8), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.uint8), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.uint16), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.uint16), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.uint32), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.uint32), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.uint64), "uint32")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.uint64), "uint32")

%% Name call
%!assert (tbcover (ex.uint32, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.uint32, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.uint32, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.uint32, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.uint64, ex.double), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.double), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.single), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.single), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.logical), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.logical), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.char), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.char), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.int8), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.int8), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.int16), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.int16), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.int32), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.int32), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.int64), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.int64), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.uint8), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.uint8), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.uint16), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.uint16), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.uint32), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.uint32), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.uint64), "uint64")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.uint64), "uint64")

%% Name call
%!assert (tbcover (ex.uint64, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.uint64, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.uint64, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.uint64, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.cell, ex.double), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.double), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.single), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.single), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.logical), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.logical), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.char), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.char), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.int8), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.int8), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.int16), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.int16), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.int32), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.int32), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.int64), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.int64), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.uint8), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.uint8), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.uint16), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.uint16), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.uint32), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.uint32), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.uint64), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.uint64), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.cell), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.cell), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.struct), "cell")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.struct), "cell")

%% Name call
%!assert (tbcover (ex.cell, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.cell, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.struct, ex.double), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.double), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.single), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.single), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.logical), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.logical), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.char), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.char), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.int8), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.int8), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.int16), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.int16), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.int32), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.int32), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.int64), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.int64), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.uint8), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.uint8), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.uint16), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.uint16), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.uint32), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.uint32), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.uint64), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.uint64), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.cell), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.cell), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.struct), "struct")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.struct), "struct")

%% Name call
%!assert (tbcover (ex.struct, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.struct, ex.function_handle), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.double), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.double), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.single), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.single), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.logical), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.logical), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.char), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.char), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.int8), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.int8), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.int16), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.int16), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.int32), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.int32), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.int64), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.int64), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.uint8), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.uint8), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.uint16), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.uint16), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.uint32), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.uint32), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.uint64), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.uint64), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.cell), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.cell), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.struct), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.struct), "function_handle")

%% Name call
%!assert (tbcover (ex.function_handle, ex.function_handle), "function_handle")
%% Handle call
%!assert ((@tbcover) (ex.function_handle, ex.function_handle), "function_handle")

%%test handles through cellfun
%!test
%! f = fieldnames (ex);
%! n = numel (f);
%! s = c1 = c2 = cell (n);
%! for i = 1:n
%!   for j = 1:n
%!     c1{i,j} = ex.(f{i});
%!     c2{i,j} = ex.(f{j});
%!     s{i,j} = tbcover (ex.(f{i}), ex.(f{j}));
%!   endfor
%! endfor
%! assert (cellfun (@tbcover, c1, c2, "uniformoutput", false), s);
