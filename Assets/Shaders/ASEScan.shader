// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASEScan"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_RimMin("RimMin", Range( -1 , 1)) = -1
		_RimMax("RimMax", Range( 0 , 2)) = 0
		_InnerColor("InnerColor", Color) = (0,0,0,0)
		_RimColor("RimColor", Color) = (0,0,0,0)
		_RImIntensity("RImIntensity", Float) = 2
		_FlowEmiss("FlowEmiss", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_FloatIntensity("FloatIntensity", Float) = 0.5
		_TexPower("TexPower", Float) = 0
		_InnerAlpha("InnerAlpha", Float) = 0.7
		_FlewTilling("FlewTilling", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha One
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform float4 _RimColor;
		uniform float _RImIntensity;
		uniform float4 _InnerColor;
		uniform float _RimMin;
		uniform float _RimMax;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _TexPower;
		uniform float _FloatIntensity;
		uniform sampler2D _FlowEmiss;
		uniform float2 _FlewTilling;
		uniform float2 _Speed;
		uniform float _InnerAlpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldNormal = i.worldNormal;
			float dotResult6 = dot( ase_worldNormal , i.viewDir );
			float clampResult7 = clamp( dotResult6 , 0.0 , 1.0 );
			float smoothstepResult15 = smoothstep( _RimMin , _RimMax , ( 1.0 - clampResult7 ));
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float clampResult50 = clamp( ( smoothstepResult15 + pow( tex2D( _MainTex, uv_MainTex ).r , _TexPower ) ) , 0.0 , 1.0 );
			float4 lerpResult20 = lerp( ( _RimColor * _RImIntensity ) , _InnerColor , clampResult50);
			float4 FinalRimColor59 = lerpResult20;
			float3 ase_worldPos = i.worldPos;
			float4 appendResult35 = (float4(ase_worldPos.x , ase_worldPos.y , 0.0 , 0.0));
			float3 objToWorld36 = mul( unity_ObjectToWorld, float4( float3( float2( 0,0 ) ,  0.0 ), 1 ) ).xyz;
			float4 appendResult39 = (float4(objToWorld36.x , objToWorld36.y , 0.0 , 0.0));
			float4 tex2DNode26 = tex2D( _FlowEmiss, ( ( ( appendResult35 - appendResult39 ) * float4( _FlewTilling, 0.0 , 0.0 ) ) + float4( ( _Speed * _Time.y ), 0.0 , 0.0 ) ).xy );
			float4 FolwColor54 = ( _FloatIntensity * tex2DNode26 );
			o.Emission = ( FinalRimColor59 + FolwColor54 ).rgb;
			float FinalRimAlpha60 = clampResult50;
			float FlowAlpha56 = ( _FloatIntensity * tex2DNode26.a );
			float clampResult43 = clamp( ( FinalRimAlpha60 + _InnerAlpha + FlowAlpha56 ) , 0.0 , 1.0 );
			o.Alpha = clampResult43;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
1920;73;1250;936;2564.445;930.2538;4.201518;True;False
Node;AmplifyShaderEditor.CommentaryNode;58;-1023.455,1101.992;Inherit;False;2336.272;521.1503;流光;18;28;45;26;46;56;54;44;30;32;29;52;53;38;37;36;33;35;39;流光;0.09789962,0.3773585,0.3097102,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;61;-997.7325,119.8657;Inherit;False;1984.857;880.1843;边缘光;20;48;4;8;7;6;5;17;15;47;1;49;16;20;59;18;21;19;22;50;60;边缘光;0.8490566,0.3404236,0.3404236,1;0;0
Node;AmplifyShaderEditor.Vector2Node;37;-973.4548,1301.04;Inherit;False;Constant;_Vector0;Vector 0;13;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WorldPosInputsNode;33;-728.2611,1151.992;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;36;-735.4101,1306.152;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;5;-882.2567,506.6161;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;4;-947.7324,365.662;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;39;-456.1958,1333.236;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;35;-470.8398,1179.878;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;6;-657.4071,442.5091;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;53;-263.1273,1385.33;Inherit;False;Property;_FlewTilling;FlewTilling;12;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;29;-48.40782,1375.54;Inherit;False;Property;_Speed;Speed;8;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;38;-254.9268,1229.336;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ClampOpNode;7;-521.2441,443.9741;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;32;-61.62669,1512.143;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-46.20054,1228.698;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;168.1445,1361.339;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-538.9248,586.342;Inherit;False;Property;_RimMin;RimMin;2;0;Create;True;0;0;0;False;0;False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-622.7883,770.0494;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;17;-548.7245,680.6746;Inherit;False;Property;_RimMax;RimMax;3;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;8;-354.7523,444.8265;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-311.9067,882.7293;Inherit;False;Property;_TexPower;TexPower;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;15;-69.98626,543.993;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;324.4435,1291.203;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;48;-75.24455,795.7469;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;501.0147,1260.529;Inherit;True;Property;_FlowEmiss;FlowEmiss;7;0;Create;True;0;0;0;False;0;False;-1;74a683c49d0030045a0abdca9fa6100a;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;608.3474,1177.8;Inherit;False;Property;_FloatIntensity;FloatIntensity;9;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;201.2542,765.5201;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;19;-137.6255,169.8657;Inherit;False;Property;_RimColor;RimColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;22;-92.3166,355.1589;Inherit;False;Property;_RImIntensity;RImIntensity;6;0;Create;True;0;0;0;False;0;False;2;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;918.3873,1335.63;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;50;388.7307,767.7861;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;18;164.2052,443.2227;Inherit;False;Property;_InnerColor;InnerColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;265.3152,334.8932;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;20;540.0393,420.7157;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;587.9051,763.6159;Inherit;False;FinalRimAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;56;1088.817,1329.728;Inherit;False;FlowAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;914.2573,1236.904;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;1214.101,403.1101;Inherit;False;56;FlowAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;63;1195.298,179.936;Inherit;False;60;FinalRimAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;1231.909,291.4882;Inherit;False;Property;_InnerAlpha;InnerAlpha;11;0;Create;True;0;0;0;False;0;False;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;763.1248,415.774;Inherit;False;FinalRimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;54;1088.383,1247.054;Inherit;False;FolwColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;1416.84,152.0133;Inherit;False;54;FolwColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;1513.14,273.629;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;1368.331,57.16272;Inherit;False;59;FinalRimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;40;1719.633,132.039;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;43;1746.78,273.6424;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2053.48,82.26824;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Scan;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;True;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;8;5;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;36;0;37;0
WireConnection;39;0;36;1
WireConnection;39;1;36;2
WireConnection;35;0;33;1
WireConnection;35;1;33;2
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;38;0;35;0
WireConnection;38;1;39;0
WireConnection;7;0;6;0
WireConnection;52;0;38;0
WireConnection;52;1;53;0
WireConnection;30;0;29;0
WireConnection;30;1;32;0
WireConnection;8;0;7;0
WireConnection;15;0;8;0
WireConnection;15;1;16;0
WireConnection;15;2;17;0
WireConnection;28;0;52;0
WireConnection;28;1;30;0
WireConnection;48;0;1;1
WireConnection;48;1;47;0
WireConnection;26;1;28;0
WireConnection;49;0;15;0
WireConnection;49;1;48;0
WireConnection;46;0;45;0
WireConnection;46;1;26;4
WireConnection;50;0;49;0
WireConnection;21;0;19;0
WireConnection;21;1;22;0
WireConnection;20;0;21;0
WireConnection;20;1;18;0
WireConnection;20;2;50;0
WireConnection;60;0;50;0
WireConnection;56;0;46;0
WireConnection;44;0;45;0
WireConnection;44;1;26;0
WireConnection;59;0;20;0
WireConnection;54;0;44;0
WireConnection;41;0;63;0
WireConnection;41;1;51;0
WireConnection;41;2;57;0
WireConnection;40;0;62;0
WireConnection;40;1;55;0
WireConnection;43;0;41;0
WireConnection;0;2;40;0
WireConnection;0;9;43;0
ASEEND*/
//CHKSM=2293083EA56F2B8EDDD57774815133241B638087