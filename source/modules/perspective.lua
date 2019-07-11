--[[ module for Love2D v. 0.10.2 ]]--

local glsl=love.graphics.newShader[[
//Made by xXxMoNkEyMaNxXx

extern Image img;
extern vec2[4] vv;

vec2 v1 = vv[0];
vec2 v2 = vv[1];
vec2 v3 = vv[2];
vec2 v4 = vv[3];

extern vec2 p0 = vec2( 0,0 );
extern vec2 rep = vec2( 1,1 );

//vertex shader --unmodified
#ifdef VERTEX

vec4 position( mat4 transform_projection, vec4 vertex_position )
{
	return transform_projection * vertex_position;
}
#endif


//pixel shader
#ifdef PIXEL

//functions used by vec4 effect
number c( vec2 v1, vec2 v2 )
{
	return v1.x*v2.y-v2.x*v1.y;
}
number intersect( vec2 v1, vec2 d1, vec2 v2, vec2 d2 )
{
	//v1+d1*
	return c( v2-v1, d2 )/c( d1, d2 );
}

vec4 effect( vec4 color, Image unused, vec2 texture_coords, vec2 screen_coords )
{
	//screen transformations

    	//position
    	vec2 positionData = vec2( TransformMatrix[3][0], TransformMatrix[3][1] );
		vec2 screenA = (screen_coords-positionData);

		//rotation
		float rotX = -TransformMatrix[1][0];
		float rotY = TransformMatrix[1][1];
		float dirX = atan( rotX, rotY );

		float sin_factor = -sin( dirX );
    	float cos_factor = cos( dirX );

		vec2 screenB = vec2( screenA.x*cos_factor, screenA.y*cos_factor ) * mat2(cos_factor, -sin_factor, sin_factor, cos_factor);

		//scale
		vec2 scaleData = vec2( TransformMatrix[0][0], TransformMatrix[1][1] );
		vec2 screen = screenB / scaleData;

	//original shader

	vec2 A1 = normalize( v2-v1 );
	vec2 A2 = normalize( v3-v4 );

	vec2 B1 = normalize( v2-v3 );
	vec2 B2 = normalize( v1-v4 );

	number Adiv = c( A1, A2 );
	number Bdiv = c( B1, B2 );

	vec2 uv;

	bvec2 eq0 = bvec2( abs(Adiv)<=0.0001, abs(Bdiv)<=0.0001 );

	if( eq0.x && eq0.y )
	{
		//Both edges are parallel, therefore the shape is a parallelogram (Isometric)
		number dis = dot( screen - v1, A1 );

		//cos theta
		number ct = dot( A1, B1 );

		//Closest point on v1->A1 to p
		vec2 pA = v1+A1*dis;

		//uv
		number r = length(screen - pA)/sqrt( 1-ct*ct );
		uv = vec2( 1-r/length(v2-v3), (dis+r*ct)/length(v2-v1) );
	} 
	else if( eq0.x )
	{
		//One Vanishing point occurs in numerically set scenarios in 3D, and is a feature of 2.5D

		//Horizon is A1 (=A2) from B
		vec2 Vp = v3+B1*c( v4-v3, B2 )/Bdiv;

		//Some point in the distance that diagonals go to
		vec2 D = Vp+A1*intersect( Vp, A1, v4, normalize(v2-v4) );

		//uv
		number u = intersect( v1, A1, Vp, normalize(screen - Vp) );
		number v = intersect( v1, A1, D, normalize(screen - D) )-u;

		number len = length( v2-v1 );
		//Reversed components to match up with other one
		uv = vec2( len-v, u )/len;
	}
	else if( eq0.y )
	{
		//If the other edge is the parallel one
		vec2 Vp = v1+A1*c(v4-v1,A2)/Adiv;
		vec2 D = Vp+B1*intersect( Vp,B1,v4,normalize(v2-v4) );
		number u = intersect( v3,B1,Vp,normalize(screen - Vp) );
		number len = length( v2-v3 );
		uv = vec2( u,len-intersect( v3, B1, D, normalize(screen - D) )+u )/len;
	}
	else
	{
		//Else, two vanishing points

		//Vanishing points
		vec2 A = v1+A1*c( v4-v1, A2 )/Adiv;
		vec2 B = v3+B1*c( v4-v3, B2 )/Bdiv;

		//Horizon
		vec2 H = normalize(A-B);

		//Pixel
		uv = vec2( intersect(v4,-H,A,normalize(screen - A))/intersect(v4,-H,v2,-A1), intersect(v4,H,B,normalize(screen - B))/intersect(v4,H,v2,-B1) );
	}

	vec4 pixel = Texel( img, mod( uv*rep+vec2(p0.x-1, p0.y), (1,1) ) ) * color;

	if (pixel.rgb == vec3(0.0)) {
		// a discarded pixel wont be applied on the stencil.
		discard;
	}

	return pixel;
}
#endif
]]

local gl_send = glsl.send
local q = love.graphics.polygon
local setShader = love.graphics.setShader

module(...)

--turn shader on before drawing any quads
function on()
	setShader( glsl )
end

--turn off when done
function off()
	setShader()
end

--origin: set at which position texture starts --format ( x,y )
--size: set how many times is repeated from origin point --format ( x,y )
function tex( origin, size )
	--predefined as ( 0,0 )
	gl_send( glsl, "p0", origin )
	--predefined as ( 1,1 )
	gl_send( glsl, "rep", size )
end

--draw quad
--vertices in clockwise order --format ( x,y )
--top-left of texture is "v1", top-right is "v2"
function quad( img, v1,v2,v3,v4 )
	--set texture
	gl_send( glsl, "img", img )
	--send vertices to calculate perspective
	gl_send( glsl, "vv", v2,v3,v4,v1,v1 )
	--generate mesh to draw into
	q( "fill", v1[1],v1[2],v2[1],v2[2],v3[1],v3[2],v4[1],v4[2] );
end