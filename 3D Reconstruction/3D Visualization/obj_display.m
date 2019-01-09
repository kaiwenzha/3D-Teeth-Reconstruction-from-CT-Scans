function obj_display ( input_file_name )

%*****************************************************************************80
%
%% OBJ_DISPLAY displays the faces of a shape defined by an OBJ file.
%
%  Usage:
%
%    obj_display ( 'file.obj' )
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    27 September 2008
%
%  Author:
%
%    John Burkardt
%
  timestamp ( );

  fprintf ( 1, '\n' );
  fprintf ( 1, 'OBJ_DISPLAY\n' );
  fprintf ( 1, '  MATLAB version\n' );
  fprintf ( 1, '\n' );
  fprintf ( 1, '  Reads an object in an ASCII OBJ file.\n' );
  fprintf ( 1, '  Display it as a MATLAB shape.\n' );
%
%  If at least one command line argument, it's the input file name.
%
  if ( nargin < 1 )

    fprintf ( 1, '\n' );
    fprintf ( 1, 'OBJ_DISPLAY:\n' );
    input_file_name = input ( 'Enter the name of the input file:' );

  end
%
%  Get sizes.
%
  [ node_num, face_num, normal_num, order_max ] = obj_size ( input_file_name );
%
%  Print the sizes.
%
  obj_size_print ( input_file_name, node_num, face_num, normal_num, order_max );
%
%  Get the data.
%
  [ node_xyz, face_order, face_node ] = ...
    obj_read ( input_file_name, node_num, face_num, normal_num, order_max );
%
%  FACE_NODE may contain polygons of different orders.
%  To make the call to PATCH, we will assume all the polygons are the same order.
%  To do so, we'll simply "stutter" the first node in each face list.
%
  for face = 1 : face_num
    face_node(face_order(face)+1:order_max,face) = face_node(1,face);
  end
%
%  If any node index is still less than 1, set the whole face to 1's.
%  We're giving up on this presumably meaningless face, but we need to
%  do it in a way that keeps MATLAB happy!
%
  for face = 1 : face_num
    for i = 1 : order_max
      face_node(i,face) = max ( face_node(i,face), 1 );
    end
  end
%
%  Display the shape.
%
  handle = patch ( 'Vertices', node_xyz', 'Faces', face_node' );
  
  set ( handle, 'FaceColor', [0.5, 0.6, 0.8], 'EdgeColor', 'Black' );

  axis equal; 
  grid on;

  xlabel ( '--X axis--' )
  ylabel ( '--Y axis--' )
  zlabel ( '--Z axis--' )
%
%  The TITLE function will interpret underscores in the title.
%  We need to unescape such escape sequences!
%
  title_string = s_escape_tex ( input_file_name );
  title ( title_string )
%
%  Terminate.
%
  fprintf ( 1, '\n' );
  fprintf ( 1, 'OBJ_DISPLAY:\n' );
  fprintf ( 1, '  Normal end of execution.\n' );

  fprintf ( 1, '\n' );
  timestamp ( );

  return
end
function c = ch_cap ( c )

%*****************************************************************************80
%
%% CH_CAP capitalizes a single character.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    22 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C, the character to capitalize.
%
%    Output, character C, the capitalized character.
%
  if ( 'a' <= c && c <= 'z' )
    c = c + 'A' - 'a';
  end

  return
end
function truefalse = ch_eqi ( c1, c2 )

%*****************************************************************************80
%
%% CH_EQI is a case insensitive comparison of two characters for equality.
%
%  Example:
%
%    CH_EQI ( 'A', 'a' ) is TRUE.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    28 July 2000
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C1, C2, the characters to compare.
%
%    Output, logical TRUEFALSE, is TRUE (1) if the characters are equal.
%
  FALSE = 0;
  TRUE = 1;

  if ( ch_cap ( c1 ) == ch_cap ( c2 ) )
    truefalse = TRUE;
  else
    truefalse = FALSE;
  end

  return
end
function value = ch_index ( s, c )

%*****************************************************************************80
%
%% CH_INDEX is the first occurrence of a character in a string.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    01 May 2004
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S, the string to be searched.
%
%    Input, character C, the character to be searched for.
%
%    Output, integer VALUE, the location of the first occurrence of C 
%    in the string, or 0 if C does not occur.
%
  value = 0;

  for i = 1 : length ( s )

    if ( s(i:i) == c )
      value = i;
      return
    end

  end

  return
end
function value = ch_is_control ( ch )

%*****************************************************************************80
%
%% CH_IS_CONTROL is TRUE if a character is a control character.
%
%  Discussion:
%
%    A "control character" has ASCII code <= 31 or 127 <= ASCII code.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    27 September 2008
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character CH, the character to be tested.
%
%    Output, integer CH_IS_CONTROL, TRUE if the character is a control
%    character, and FALSE otherwise.
%
  if ( ch <= 31 || 127 <= ch )
    value = 1;
  else
    value = 0;
  end

  return
end
function truefalse = ch_is_digit ( c )

%*****************************************************************************80
%
% CH_IS_DIGIT returns TRUE if the character C is a digit.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    11 December 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C, a character.
%
%    Output, integer TRUEFALSE, is TRUE (1) if C is a digit, FALSE (0) otherwise.
%
  TRUE = 1;
  FALSE = 0;

  if ( '0' <= c && c <= '9' )
    truefalse = TRUE;
  else
    truefalse = FALSE;
  end

  return
end
function digit = ch_to_digit ( c )

%*****************************************************************************80
%
%% CH_TO_DIGIT returns the integer value of a base 10 digit.
%
%  Example:
%
%     C   DIGIT
%    ---  -----
%    '0'    0
%    '1'    1
%    ...  ...
%    '9'    9
%    ' '    0
%    'X'   -1
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    22 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, character C, the decimal digit, '0' through '9' or blank
%    are legal.
%
%    Output, integer DIGIT, the corresponding integer value.  If C was
%    'illegal', then DIGIT is -1.
%
  if ( '0' <= c && c <= '9' )

    digit = c - '0';

  elseif ( c == ' ' )

    digit = 0;

  else

    digit = -1;

  end

  return
end
function [ node_xyz, face_order, face_node, normal_vector, vertex_normal ] = ...
  obj_read ( input_file_name, node_num, face_num, normal_num, order_max )

%*****************************************************************************80
%
%% OBJ_READ reads graphics information from a Wavefront OBJ file.
%
%  Discussion:
%
%    It is intended that the information read from the file can
%    either start a whole new graphics object, or simply be added
%    to a current graphics object via the '<<' command.
%
%    This is controlled by whether the input values have been zeroed
%    out or not.  This routine simply tacks on the information it
%    finds to the current graphics object.
%
%  Example:
%
%    #  magnolia.obj
%
%    v -3.269770 -39.572201 0.876128
%    v -3.263720 -39.507999 2.160890
%    ...
%    v 0.000000 -9.988540 0.000000
%    vn 1.0 0.0 0.0
%    ...
%    vn 0.0 1.0 0.0
%
%    f 8 9 11 10
%    f 12 13 15 14
%    ...
%    f 788 806 774
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    27 September 2008
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string INPUT_FILE_NAME, the name of the input file.
%
%    Input, integer NODE_NUM, the number of points.
%
%    Input, integer FACE_NUM, the number of faces.
%
%    Input, integer NORMAL_NUM, the number of normal vectors.
%
%    Input, integer ORDER_MAX, the maximum number of vertices per face.
%
%    Output, real NODE_XYZ(3,NODE_NUM), the coordinates of points.
%
%    Output, integer FACE_ORDER(FACE_NUM), the number of vertices per face.
%
%    Output, integer FACE_NODE(ORDER_MAX,FACE_NUM), the nodes making faces.
%
%    Output, real NORMAL_VECTOR(3,NORMAL_NUM), normal vectors.
%
%    Output, integer VERTEX_NORMAL(ORDER_MAX,FACE_NUM), the indices of normal
%    vectors per vertex.
%
  face = 0;
  node = 0;
  normal = 0;
  text_num = 0;

  face_node = zeros ( order_max, face_num );
  face_order = zeros ( face_num, 1 );
  node_xyz = zeros ( 3, node_num );
  normal_vector = zeros ( 3, normal_num );
  vertex_normal = zeros ( order_max, face_num );
%
%  If no file input, try to get one from the user.
%
  if ( nargin < 1 )
    input_file_name = input ( 'Enter the name of the ASCII OBJ file.' );
    if ( isempty ( input_file_name ) )
      return
    end
  end
%
%  Open the file.
%
  input_file_unit = fopen ( input_file_name, 'r' );

  if ( input_file_unit < 0 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'OBJ_READ - Fatal error!\n' );
    fprintf ( 1, '  Could not open the file "%s".\n', input_file_name );
    error ( 'OBJ_READ - Fatal error!' );
  end
%
%  Read a line of text from the file.
%
  while ( 1 )

    text = fgetl ( input_file_unit );

    if ( text == -1 )
      break
    end

    text_num = text_num + 1;
%
%  Replace any control characters (in particular, TAB's) by blanks.
%
    s_control_blank ( text );

    done = 1;
    word_index = 0;
%
%  Read a word from the line.
%
    [ word, done ] = word_next_read ( text, done );
%
%  If no more words in this line, read a new line.
%
    if ( done )
      continue
    end
%
%  If this word begins with '#' or '$', then it's a comment.  Read a new line.
%
    if ( word(1) == '#' || word(1) == '$' )
      continue
    end

    word_index = word_index + 1;

    if ( word_index == 1 )
      word_one = word;
    end
%
%  BEVEL
%  Bevel interpolation.
%
    if ( s_eqi ( word_one, 'BEVEL' ) )
%
%  BMAT
%  Basis matrix.
%
    elseif ( s_eqi ( word_one, 'BMAT' ) )
%
%  C_INTERP
%  Color interpolation.
%
    elseif ( s_eqi ( word_one, 'C_INTERP' ) )
%
%  CON
%  Connectivity between free form surfaces.
%
    elseif ( s_eqi ( word_one, 'CON' ) )
%
%  CSTYPE
%  Curve or surface type.
%
    elseif ( s_eqi ( word_one, 'CSTYPE' ) )
%
%  CTECH
%  Curve approximation technique.
%
    elseif ( s_eqi ( word_one, 'CTECH' ) )
%
%  CURV
%  Curve.
%
    elseif ( s_eqi ( word_one, 'CURV' ) )
%
%  CURV2
%  2D curve.
%
    elseif ( s_eqi ( word_one, 'CURV2' ) )
%
%  D_INTERP
%  Dissolve interpolation.
%
    elseif ( s_eqi ( word_one, 'D_INTERP' ) )
%
%  DEG
%  Degree.
%
    elseif ( s_eqi ( word_one, 'DEG' ) )
%
%  END
%  End statement.
%
    elseif ( s_eqi ( word_one, 'END' ) )
%
%  F V1 V2 V3 ...
%    or
%  F V1/VT1/VN1 V2/VT2/VN2 ...
%    or
%  F V1//VN1 V2//VN2 ...
%
%  Face.
%  A face is defined by the vertices.
%  Optionally, slashes may be used to include the texture vertex
%  and vertex normal indices.
%
    elseif ( s_eqi ( word_one, 'F' ) )

      face = face + 1;

      vertex = 0;

      while ( 1 )

        [ word, done ] = word_next_read ( text, done );

        if ( done )
          break
        end

        vertex = vertex + 1;
        order_max = max ( order_max, vertex );
%
%  Locate the slash characters in the word, if any.
%
        i1 = ch_index ( word, '/' );
        if ( 0 < i1 )
          i2 = ch_index ( word(i1+1), '/' ) + i1;
        else
          i2 = 0;
        end
%
%  Read the vertex index.
%
        itemp = s_to_i4 ( word );

        face_node(vertex,face) = itemp;
        face_order(face) = face_order(face) + 1;
%
%  If there are two slashes, then read the data following the second one.
%
        if ( 0 < i2 )

          itemp = s_to_i4 ( word(i2+1) );

          vertex_normal(vertex,face) = itemp;

        end

      end
%
%  G
%  Group name.
%
    elseif ( s_eqi ( word_one, 'G' ) )
%
%  HOLE
%  Inner trimming loop.
%
    elseif ( s_eqi ( word_one, 'HOLE' ) )
%
%  L
%  A line, described by a sequence of vertex indices.
%  Are the vertex indices 0 based or 1 based?
%
    elseif ( s_eqi ( word_one, 'L' ) )
%
%  LOD
%  Level of detail.
%
    elseif ( s_eqi ( word_one, 'LOD' ) )
%
%  MG
%  Merging group.
%
    elseif ( s_eqi ( word_one, 'MG' ) )
%
%  MTLLIB
%  Material library.
%
    elseif ( s_eqi ( word_one, 'MTLLIB' ) )
%
%  O
%  Object name.
%
    elseif ( s_eqi ( word_one, 'O' ) )
%
%  P
%  Point.
%
    elseif ( s_eqi ( word_one, 'P' ) )
%
%  PARM
%  Parameter values.
%
    elseif ( s_eqi ( word_one, 'PARM' ) )
%
%  S
%  Smoothing group.
%
    elseif ( s_eqi ( word_one, 'S' ) )
%
%  SCRV
%  Special curve.
%
    elseif ( s_eqi ( word_one, 'SCRV' ) )
%
%  SHADOW_OBJ
%  Shadow casting.
%
    elseif ( s_eqi ( word_one, 'SHADOW_OBJ' ) )
%
%  SP
%  Special point.
%
    elseif ( s_eqi ( word_one, 'SP' ) )
%
%  STECH
%  Surface approximation technique.
%
    elseif ( s_eqi ( word_one, 'STECH' ) )
%
%  STEP
%  Stepsize.
%
    elseif ( s_eqi ( word_one, 'STEP' ) )
%
%  SURF
%  Surface.
%
    elseif ( s_eqi ( word_one, 'SURF' ) )
%
%  TRACE_OBJ
%  Ray tracing.
%
    elseif ( s_eqi ( word_one, 'TRACE_OBJ' ) )
%
%  TRIM
%  Outer trimming loop.
%
    elseif ( s_eqi ( word_one, 'TRIM' ) )
%
%  USEMTL
%  Material name.
%
    elseif ( s_eqi ( word_one, 'USEMTL' ) )
%
%  V X Y Z
%  Geometric vertex.
%
    elseif ( s_eqi ( word_one, 'V' ) )

      node = node + 1;

      for i = 1 : 3
        [ word, done ] = word_next_read ( text, done );
        temp = s_to_r8 ( word );
        node_xyz(i,node) = temp;
      end
%
%  VN
%  Vertex normals.
%
    elseif ( s_eqi ( word_one, 'VN' ) )

      normal = normal + 1;

      for i = 1 : 3
        [ word, done ] = word_next_read ( text, done );
        temp = s_to_r8 ( word );
        normal_vector(i,normal) = temp;
      end
%
%  VT
%  Vertex texture.
%
    elseif ( s_eqi ( word_one, 'VT' ) )
%
%  VP
%  Parameter space vertices.
%
    elseif ( s_eqi ( word_one, 'VP' ) )
%
%  Unrecognized keyword.
%
    else

    end

  end

  fclose ( input_file_unit );

  return
end
function [ node_num, face_num, normal_num, order_max ] = obj_size ( ...
  input_file_name )

%*****************************************************************************80
%
%% OBJ_SIZE determines sizes of graphics objects in an Alias OBJ file.
%
%  Discussion:
%
%    The only items of interest to this routine are vertices,
%    faces, and normal vectors.
%
%  Example:
%
%    #  magnolia.obj
%
%    v -3.269770 -39.572201 0.876128
%    v -3.263720 -39.507999 2.160890
%    ...
%    v 0.000000 -9.988540 0.000000
%
%    vn 1.0 0.0 0.0
%    ...
%    vn 0.0 1.0 0.0
%
%    f 8 9 11 10
%    f 12 13 15 14
%    ...
%    f 788 806 774
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    26 September 2008
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string INPUT_FILE_NAME, the input file name.
%
%    Output, integer NODE_NUM, the number of points.
%
%    Output, integer FACE_NUM, the number of faces.
%
%    Output, integer NORMAL_NUM, the number of normal vectors.
%
%    Output, integer ORDER_MAX, the maximum face order.
%
  face_num = 0;
  node_num = 0;
  normal_num = 0;
  order_max = 0;
  text_num = 0;
%
%  If no file input, try to get one from the user.
%
  if ( nargin < 1 )
    input_file_name = input ( 'Enter the name of the ASCII OBJ file.' );
    if ( isempty ( input_file_name ) )
      return
    end
  end
%
%  Open the file.
%
  input_file_unit = fopen ( input_file_name, 'r' );

  if ( input_file_unit < 0 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'OBJ_SIZE - Fatal error!\n' );
    fprintf ( 1, '  Could not open the file "%s".\n', input_file_name );
    error ( 'OBJ_SIZE - Fatal error!' );
  end
%
%  Read a line of text from the file.
%
  while ( 1 )

    text = fgetl ( input_file_unit );

    if ( text == -1 )
      break
    end

    text_num = text_num + 1;
%
%  Replace any control characters (in particular, TABs) by blanks.
%
    s_control_blank ( text );

    done = 1;
    word_index = 0;
%
%  Read a word from the line.
%
    [ word, done ] = word_next_read ( text, done );
%
%  If no more words in this line, read a new line.
%
    if ( done )
      continue
    end
%
%  If this word begins with '#' or '$', then it is a comment.  Read a new line.
%
    if ( word(1) == '#' || word(1) == '$' )
      continue
    end

    word_index = word_index + 1;

    if ( word_index == 1 )
      word_one = word;
    end
%
%  F V1 V2 V3 ...
%    or
%  F V1/VT1/VN1 V2/VT2/VN2 ...
%    or
%  F V1//VN1 V2//VN2 ...
%
%  Face.
%  A face is defined by the vertices.
%  Optionally, slashes may be used to include the texture vertex
%  and vertex normal indices.
%
    if ( s_eqi ( word_one, 'F' ) )

      face_num = face_num + 1;

      vertex = 0;

      while ( 1 )

        [ word, done ] = word_next_read ( text, done );

        if ( done )
          break
        end

        vertex = vertex + 1;
        order_max = max ( order_max, vertex );
%
%  Locate the slash characters in the word, if any.
%
        i1 = ch_index ( word, '/' );
        if ( 0 < i1 )
          i2 = ch_index ( word(i1+1), '/' ) + i1;
        else
          i2 = 0;
        end
%
%  Read the vertex index.
%
        s_to_i4 ( word );
%
%  If there are two slashes, then read the data following the second one.
%
        if ( 0 < i2 )
          s_to_i4 ( word(i2+1) );
        end

      end
%
%  V X Y Z W
%  Geometric vertex.
%
    elseif ( s_eqi ( word_one, 'V' ) )

      node_num = node_num + 1;
      continue
%
%  VN
%  Vertex normals.
%
    elseif ( s_eqi ( word_one, 'VN' ) )

      normal_num = normal_num + 1;
      continue

    end

  end

  fclose ( input_file_unit );

  return
end
function obj_size_print ( input_file_name, node_num, face_num, normal_num, ...
  order_max )

%*****************************************************************************80
%
%% OBJ_SIZE_PRINT prints sizes associated with an OBJ file.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    26 September 2008
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string INPUT_FILE_NAME, the name of the input file.
%
%    Input, integer NODE_NUM, the number of vertices defined.
%
%    Input, integer FACE_NUM, the number of faces defined.
%
%    Input, integer NORMAL_NUM, the number of normal vectors defined.
%
%    Input, integer ORDER_MAX, the maximum number of vertices per face.
%
  fprintf ( 1, '\n' );
  fprintf ( 1, '  Object sizes for OBJ file "%s":\n', input_file_name );
  fprintf ( 1, '\n' );
  fprintf ( 1, '  Nodes              = %d\n', node_num );
  fprintf ( 1, '  Faces              = %d\n', face_num );
  fprintf ( 1, '  Maximum face order = %d\n', order_max );
  fprintf ( 1, '  Normal vectors     = %d\n', normal_num );

  return
end
function s = s_control_blank ( s )

%*****************************************************************************80
%
%% S_CONTROL_BLANK replaces control characters with blanks.
%
%  Discussion:
%
%    A "control character" has ASCII code <= 31 or 127 <= ASCII code.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    27 September 2008
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input/output, string S, the string to be transformed.
%
  s_length = s_len_trim ( s );

  for i = 1 : s_length
    if ( ch_is_control ( s(i) ) )
      s(i) = ' ';
    end
  end

  return
end
function value = s_eqi ( s1, s2 )

%*****************************************************************************80
%
%% S_EQI is a case insensitive comparison of two strings for equality.
%
%  Example:
%
%    S_EQI ( 'Anjana', 'ANJANA' ) is TRUE.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    30 April 2004
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S1, S2, the strings to compare.
%
%    Output, logical VALUE, is TRUE if the strings are equal.
%
  FALSE = 0;
  TRUE = 1;

  len1 = length ( s1 );
  len2 = length ( s2 );
  lenc = min ( len1, len2 );

  for i = 1 : lenc

    c1 = ch_cap ( s1(i) );
    c2 = ch_cap ( s2(i) );

    if ( c1 ~= c2 )
      value = FALSE;
      return
    end

  end

  for i = lenc + 1 : len1
    if ( s1(i) ~= ' ' )
      value = FALSE;
      return
    end
  end

  for i = lenc + 1 : len2
    if ( s2(i) ~= ' ' )
      value = FALSE;
      return
    end
  end

  value = TRUE;

  return
end
function s2 = s_escape_tex ( s1 )

%*****************************************************************************80
%
%% S_ESCAPE_TEX de-escapes TeX escape sequences.
%
%  Discussion:
%
%    In particular, every occurrence of the characters '\', '_',
%    '^', '{' and '}' will be replaced by '\\', '\_', '\^',
%    '\{' and '\}'.  A TeX interpreter, on seeing these character
%    strings, is then likely to return the original characters.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    19 January 2007
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S1, the string to be de-escaped.
%
%    Output, string S2, a copy of the string, modified to avoid TeX escapes.
%
  s1_length = length ( s1 );

  s1_pos = 0;
  s2_pos = 0;
  s2 = [];

  while ( s1_pos < s1_length )

    s1_pos = s1_pos + 1;

    if ( s1(s1_pos) == '\' || ...
         s1(s1_pos) == '_' || ...
         s1(s1_pos) == '^' || ...
         s1(s1_pos) == '{' || ...
         s1(s1_pos) == '}' )
      s2_pos = s2_pos + 1;
      s2 = strcat ( s2, '\' );
    end

    s2_pos = s2_pos + 1;
    s2 = strcat ( s2, s1(s1_pos) );

  end

  return
end
function len = s_len_trim ( s )

%*****************************************************************************80
%
%% S_LEN_TRIM returns the length of a character string to the last nonblank.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    14 June 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S, the string to be measured.
%
%    Output, integer LEN, the length of the string up to the last nonblank.
%
  len = length ( s );

  while ( 0 < len )
    if ( s(len) ~= ' ' )
      return
    end
    len = len - 1;
  end

  return
end
function ival = s_to_i4 ( s )

%*****************************************************************************80
%
%% S_TO_I4 reads an integer value from a string.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    18 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S, a string to be examined.
%
%    Output, integer IVAL, the integer value read from the string.
%
  sgn = 1;
  state = 0;
  ival = 0;

  i = 0;

  while ( i < s_len_trim ( s ) )

    i = i + 1;
    c = s(i);

    if ( state == 0 )

      if ( c == ' ' )

      elseif ( c == '-' )
        state = 1;
        sgn = -1;
      elseif ( c == '+' )
        state = 1;
        sgn = +1;
      elseif ( '0' <= c && c <= '9' )
        state = 2;
        ival = c - '0';
      else
        fprintf ( '\n' );
        fprintf ( 'S_TO_I4 - Fatal error!\n' );
        fprintf ( '  Illegal character %c while in state %d.\n', c, state );
        return;
      end
%
%  Have read the sign, now expecting the first digit.
%
    elseif ( state == 1 )

      if ( c == ' ' )

      elseif ( '0' <= c && c <= '9' )
        state = 2;
        ival = c - '0';
      else
        fprintf ( '\n' );
        fprintf ( 'S_TO_I4 - Fatal error!\n' );
        fprintf ( '  Illegal character %c while in state %d.\n', c, state );
        return
      end
%
%  Have read at least one digit, expecting more.
%
    elseif ( state == 2 )

      if ( '0' <= c && c <= '9' )
        ival = 10 * ival + c - '0';
      else
        ival = sgn * ival;
        return;
      end

    end

  end
%
%  If we read all the characters in the string, see if we're OK.
%
  if ( state ~= 2 )
    fprintf ( '\n' );
    fprintf ( 'S_TO_I4 - Fatal error!\n' );
    fprintf ( '  Did not read enough information to define an integer!\n' );
    return;
  end

  ival = sgn * ival;

  return
end
function [ r, lchar, ierror ] = s_to_r8 ( s )

%*****************************************************************************80
%
%% S_TO_R8 reads an R8 from a string.
%
%  Discussion:
%
%    This routine will read as many characters as possible until it reaches
%    the end of the string, or encounters a character which cannot be
%    part of the real number.
%
%    Legal input is:
%
%       1 blanks,
%       2 '+' or '-' sign,
%       2.5 spaces
%       3 integer part,
%       4 decimal point,
%       5 fraction part,
%       6 'E' or 'e' or 'D' or 'd', exponent marker,
%       7 exponent sign,
%       8 exponent integer part,
%       9 exponent decimal point,
%      10 exponent fraction part,
%      11 blanks,
%      12 final comma or semicolon.
%
%    with most quantities optional.
%
%  Example:
%
%    S                 R
%
%    '1'               1.0
%    '     1   '       1.0
%    '1A'              1.0
%    '12,34,56'        12.0
%    '  34 7'          34.0
%    '-1E2ABCD'        -100.0
%    '-1X2ABCD'        -1.0
%    ' 2E-1'           0.2
%    '23.45'           23.45
%    '-4.2E+2'         -420.0
%    '17d2'            1700.0
%    '-14e-2'         -0.14
%    'e2'              100.0
%    '-12.73e-9.23'   -12.73 * 10.0**(-9.23)
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    22 November 2003
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S, the string containing the
%    data to be read.  Reading will begin at position 1 and
%    terminate at the end of the string, or when no more
%    characters can be read to form a legal real.  Blanks,
%    commas, or other nonnumeric data will, in particular,
%    cause the conversion to halt.
%
%    Output, real R, the value that was read from the string.
%
%    Output, integer LCHAR, the number of characters of S that were used to form R.
%
%    Output, integer IERROR, is 0 if no error occurred.
%
  s_length = s_len_trim ( s );
  ierror = 0;
  lchar = -1;
  isgn = 1;
  rtop = 0.0;
  rbot = 1.0;
  jsgn = 1;
  jtop = 0;
  jbot = 1;
  ihave = 1;
  iterm = 0;

  while ( 1 )

    lchar = lchar + 1;
    c = s(lchar+1);
%
%  Blank character.
%
    if ( c == ' ' )

      if ( ihave == 2 )

      elseif ( ihave == 6 || ihave == 7 )
        iterm = 1;
      elseif ( 1 < ihave )
        ihave = 11;
      end
%
%  Comma.
%
    elseif ( c == ',' || c == ';' )

      if ( ihave ~= 1 )
        iterm = 1;
        ihave = 12;
        lchar = lchar + 1;
      end
%
%  Minus sign.
%
    elseif ( c == '-' )

      if ( ihave == 1 );
        ihave = 2;
        isgn = -1;
      elseif ( ihave == 6 )
        ihave = 7;
        jsgn = -1;
      else
        iterm = 1;
      end
%
%  Plus sign.
%
    elseif ( c == '+' )

      if ( ihave == 1 )
        ihave = 2;
      elseif ( ihave == 6 )
        ihave = 7;
      else
        iterm = 1;
      end
%
%  Decimal point.
%
    elseif ( c == '.' )

      if ( ihave < 4 )
        ihave = 4;
      elseif ( 6 <= ihave && ihave <= 8 )
        ihave = 9;
      else
        iterm = 1;
      end
%
%  Exponent marker.
%
    elseif ( ch_eqi ( c, 'E' ) || ch_eqi ( c, 'D' ) )

      if ( ihave < 6 )
        ihave = 6;
      else
        iterm = 1;
      end
%
%  Digit.
%
    elseif ( ihave < 11 && ch_is_digit ( c ) )

      if ( ihave <= 2 )
        ihave = 3;
      elseif ( ihave == 4 )
        ihave = 5;
      elseif ( ihave == 6 || ihave == 7 )
        ihave = 8;
      elseif ( ihave == 9 )
        ihave = 10;
      end

      d = ch_to_digit ( c );

      if ( ihave == 3 )
        rtop = 10.0 * rtop + d;
      elseif ( ihave == 5 )
        rtop = 10.0 * rtop + d;
        rbot = 10.0 * rbot;
      elseif ( ihave == 8 )
        jtop = 10 * jtop + d;
      elseif ( ihave == 10 )
        jtop = 10 * jtop + d;
        jbot = 10 * jbot;
      end
%
%  Anything else is regarded as a terminator.
%
    else
      iterm = 1;
    end
%
%  If we haven't seen a terminator, and we haven't examined the
%  entire string, go get the next character.
%
    if ( iterm == 1 || s_length <= lchar + 1 )
      break;
    end

  end
%
%  If we haven't seen a terminator, and we have examined the
%  entire string, then we're done, and LCHAR is equal to S_LENGTH.
%
  if ( iterm ~= 1 && lchar + 1 == s_length )
    lchar = s_length;
  end
%
%  Number seems to have terminated.  Have we got a legal number?
%  Not if we terminated in states 1, 2, 6 or 7!
%
  if ( ihave == 1 || ihave == 2 || ihave == 6 || ihave == 7 )
    fprintf ( 1, '\n' );
    fprintf ( 1, 'S_TO_R8 - Fatal error!\n' );
    fprintf ( 1, '  IHAVE = %d\n', ihave );
    error ( 'S_TO_R8 - Fatal error!' );
  end
%
%  Number seems OK.  Form it.
%
  if ( jtop == 0 )
    rexp = 1.0;
  else

    if ( jbot == 1 )
      rexp = 10.0^( jsgn * jtop );
    else
      rexp = jsgn * jtop;
      rexp = rexp / jbot;
      rexp = 10.0^rexp;
    end

  end

  r = isgn * rexp * rtop / rbot;

  return
end
function timestamp ( )

%*****************************************************************************80
%
%% TIMESTAMP prints the current YMDHMS date as a timestamp.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    14 February 2003
%
%  Author:
%
%    John Burkardt
%
  t = now;
  c = datevec ( t );
  s = datestr ( c, 0 );
  fprintf ( 1, '%s\n', s );

  return
end
function [ word, done ] = word_next_read ( s, done )

%*****************************************************************************80
%
%% WORD_NEXT_READ "reads" words from a string, one at a time.
%
%  Special cases:
%
%    The following characters are considered to be a single word,
%    whether surrounded by spaces or not:
%
%      " ( ) { } [ ]
%
%    Also, if there is a trailing comma on the word, it is stripped off.
%    This is to facilitate the reading of lists.
%
%  Licensing:
%
%    This code is distributed under the GNU LGPL license.
%
%  Modified:
%
%    24 September 2005
%
%  Author:
%
%    John Burkardt
%
%  Parameters:
%
%    Input, string S, a string, presumably containing words
%    separated by spaces.
%
%    Input, logical DONE.
%    TRUE, if we are beginning a new string;
%    FALSE, if we are continuing to process the current string.
%
%    Output, string WORD.
%    If DONE is FALSE, then WORD contains the "next" word read.
%    If DONE is TRUE, then WORD is blank, because there was no more to read.
%
%    Output, logical DONE.
%      FALSE if another word was read,
%      TRUE if no more words could be read.
%
  persistent lenc;
  persistent next;
  
  tab = char ( 9 );
%
%  We "remember" LENC and NEXT from the previous call.
%
%  An input value of DONE = TRUE signals a new line of text to examine.
%
  if ( done )

    next = 1;
    done = 0;
    lenc = s_len_trim ( s );

    if ( lenc <= 0 )
      done = 1;
      word = ' ';
      return
    end

  end
%
%  Beginning at index NEXT, search the string for the next nonblank,
%  which signals the beginning of a word.
%
  ilo = next;
%
%  ...S(NEXT:) is blank.  Return with WORD = ' ' and DONE = TRUE.
%
  while ( 1 )

    if ( lenc < ilo )
      word = ' ';
      done = 1;
      next = lenc + 1;
      return
    end
%
%  If the current character is blank, skip to the next one.
%
    if ( s(ilo) ~= ' ' && s(ilo) ~= tab )
      break
    end

    ilo = ilo + 1;

  end
%
%  ILO is the index of the next nonblank character in the string.
%
%  If this initial nonblank is a special character,
%  then that's the whole word as far as we're concerned,
%  so return immediately.
%
  if ( s(ilo) == '"' || ...
       s(ilo) == '(' || ...
       s(ilo) == ')' || ...
       s(ilo) == '{' || ...
       s(ilo) == '}' || ...
       s(ilo) == '[' || ...
       s(ilo) == ']' )

    word = s(ilo);
    next = ilo + 1;
    return

  end
%
%  Now search for the last contiguous character that is not a
%  blank, TAB, or special character.
%
  next = ilo + 1;

  while ( next <= lenc )

    if ( s(next) == ' ' )
      break;
    elseif ( s(next) == tab )
      break;
    elseif ( s(next) == '"' )
      break;
    elseif ( s(next) == '(' )
      break;
    elseif ( s(next) == ')' )
      break;
    elseif ( s(next) == '{' )
      break;
    elseif ( s(next) == '}' )
      break;
    elseif ( s(next) == '[' )
      break;
    elseif ( s(next) == ']' )
      break;
    end

    next = next + 1;

  end

  if ( s(next-1) == ',' ) 
    word = s(ilo:next-2);
  else
    word = s(ilo:next-1);
  end

  return
end