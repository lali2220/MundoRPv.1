/*
GM base by KRISSTI4N
Contiene:
-Registro
-Ingreso
-Guardado automatico de informacion
-Cargado automatico de informacion
*/

//Includes
#include <a_samp>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <zcmd>


#define SERVER_NAME     "[Mundo Roleplay] | Trabajo, Acción y Diversión"

//Configuracion
#define SQL_HOST 		"localhost"
#define SQL_USUARIO 	"root"
#define SQL_CONTRA 		""
#define SQL_DB 			"mundorp"
//Colores
#define VERDECLARO 0x00FF00FF
//Atajos
#define SCM SendClientMessage
#define SPP SetPlayerPos
//Dialogos
#define DIALOG_REGISTRO   0
#define DIALOG_GENERO     1
#define DIALOG_EDAD       2
#define DIALOG_INGRESO    3
//news
new MySQL;
//Enum
enum jInfo
{
	Contra[128],
	Genero,
	Edad,
	Ropa,
	Float:X,
	Float:Y,
	Float:Z,
	Float:Vida,
	Float:Chaleco,
	Muertes,
	Asesinatos,
	Faccion,
	Rango,
	Trabajo,
	Dinero,
	Int,
	VW,
	Nivel,
	Coins,
	PuntosRol,
	Admin,
    Float:x_afuera,
    Float:y_afuera,
    Float:z_afuera,
    Float:x_dentro,
    Float:y_dentro,
    Float:z_dentro,
    interior,
    vw,
    pickup_afuera,
    pickup_dentro,
    Text3D:label_afuera,
    Text3D:label_dentro
};
new Puertas[100][jInfo];
new TotalPuertas = 0;
new gLastDoorUseTick[MAX_PLAYERS];

new Jugador[MAX_PLAYERS][jInfo];
//Forward
forward VerificarUsuario(playerid);
forward CrearCuenta(playerid);
forward IngresoJugador(playerid);
forward IngresarJugador(playerid);
forward GuardarJugador(playerid);
//

main()
{
	print("Mundo Roleplay");
}


public OnGameModeInit()
{
    new rcon[80];
    format(rcon, sizeof(rcon), "hostname %s", SERVER_NAME);
    SendRconCommand(rcon);
	SetGameModeText("MRP - V1.1");
	SendRconCommand("loadfs maps");
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(false);

    Create3DTextLabel("Presiona F para usar la puerta", 0x00FF00FF, 0.0, 0.0, 0.0, 10.0, 0, 1);

    MySQL = mysql_connect(SQL_HOST,SQL_USUARIO,SQL_DB,SQL_CONTRA);
    if(mysql_errno() == 0)
    {
        print("Conectado.");
        CargarPuertas(); // <--- AQUÍ
        print("CargarPuertas llamada.");
    }
    else
    {
        print("No se pudo conectar.");
    }
    // ... otros códigos ...
    return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

stock CargarPuertas()
{
    mysql_tquery(MySQL, "SELECT * FROM puertas", "OnPuertasCargadas", "");
}

forward OnPuertasCargadas();
public OnPuertasCargadas()
{
    new filas = cache_num_rows();
    printf("DEBUG: filas puertas = %d", filas);
    for(new i = 0; i < filas; i++)
    {
        printf("DEBUG: Cargando puerta %d", i);
        Puertas[i][x_afuera] = cache_get_field_content_float(i, "x_afuera");
        Puertas[i][y_afuera] = cache_get_field_content_float(i, "y_afuera");
        Puertas[i][z_afuera] = cache_get_field_content_float(i, "z_afuera");
        Puertas[i][x_dentro] = cache_get_field_content_float(i, "x_dentro");
        Puertas[i][y_dentro] = cache_get_field_content_float(i, "y_dentro");
        Puertas[i][z_dentro] = cache_get_field_content_float(i, "z_dentro");
        Puertas[i][interior] = cache_get_field_content_int(i, "interior");
        Puertas[i][vw] = cache_get_field_content_int(i, "vw");

        new textoLabel[] = "{FFFF00}Presiona {00FF00}F {FFFF00}para usar la puerta";

        // ENTRADA (afuera)
        Puertas[i][label_afuera] = Create3DTextLabel(
            textoLabel,
            0xFFFFFFFF,
            Puertas[i][x_afuera],
            Puertas[i][y_afuera],
            Puertas[i][z_afuera] + 1.0,
            20.0, 0, 1
        );
        Puertas[i][pickup_afuera] = CreatePickup(
            1239,
            1,
            Puertas[i][x_afuera],
            Puertas[i][y_afuera],
            Puertas[i][z_afuera]
        );

        // SALIDA (adentro)
        Puertas[i][label_dentro] = Create3DTextLabel(
            textoLabel,
            0xFFFFFFFF,
            Puertas[i][x_dentro],
            Puertas[i][y_dentro],
            Puertas[i][z_dentro] + 1.0,
            20.0, 0, 1
        );
        Puertas[i][pickup_dentro] = CreatePickup(
            1239,
            1,
            Puertas[i][x_dentro],
            Puertas[i][y_dentro],
            Puertas[i][z_dentro]
        );
    }
    TotalPuertas = filas;
    printf("Puertas cargadas: %d", filas);
}


public OnPlayerConnect(playerid)
{
	new query[520],nombre[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nombre, sizeof(nombre));
	mysql_format(MySQL, query, sizeof(query), "SELECT * FROM `cuentas` WHERE `Nombre`='%s'", nombre);
	mysql_pquery(MySQL, query, "VerificarUsuario","d", playerid);

    // Verificar si el nombre contiene un guion bajo '_'
   	if(strfind(nombre, "_", true) == -1)
   	{
		for(new i = 0; i < 20; i++)
      	{
        	SendClientMessage(playerid, -1, " ");
      	}
      	SendClientMessage(playerid, -1, "Debes ingresar con un nombre en formato de rol: Nombre_Apellido (ejemplo: Alex_Martines).");
      	SendClientMessage(playerid, -1, "Vuelve a conectarte con un nombre válido para poder jugar.");
      	SetTimerEx("KickWelcome", 2000, false, "i", playerid);
      	return 0;
	}

	for(new i = 0; i < 20; i++)
	{
		SendClientMessage(playerid, -1, " ");
	}
	return 1;
}

forward KickWelcome(playerid);
public KickWelcome(playerid)
{
    if(IsPlayerConnected(playerid))
    {
        Kick(playerid);
    }
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	GuardarJugador(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(GetPVarInt(playerid, "PuedeIngresar") == 0)
	{
		Kick(playerid);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	Jugador[playerid][Muertes]++;
	Jugador[killerid][Asesinatos]++;
	return 1;
}




public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	// Detectar PRESIÓN de F (no mantener, no soltar)
	if( (newkeys & KEY_SECONDARY_ATTACK) && !(oldkeys & KEY_SECONDARY_ATTACK) )
	{
		// Evitar si está en vehículo
		if(IsPlayerInAnyVehicle(playerid)) return 1;

		// Anti-spam 500ms
		new now = GetTickCount();
		if(now - gLastDoorUseTick[playerid] < 500) return 1;
		gLastDoorUseTick[playerid] = now;

		for(new i = 0; i < TotalPuertas; i++)
		{
			// Afuera -> Dentro
			if(IsPlayerInRangeOfPoint(playerid, 2.0, Puertas[i][x_afuera], Puertas[i][y_afuera], Puertas[i][z_afuera]))
			{
				SetPlayerInterior(playerid, Puertas[i][interior]);
				SetPlayerVirtualWorld(playerid, Puertas[i][vw]);
				SetPlayerPos(playerid, Puertas[i][x_dentro], Puertas[i][y_dentro], Puertas[i][z_dentro]);
				return 1;
			}
			// Dentro -> Afuera
			if(IsPlayerInRangeOfPoint(playerid, 2.0, Puertas[i][x_dentro], Puertas[i][y_dentro], Puertas[i][z_dentro]))
			{
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerPos(playerid, Puertas[i][x_afuera], Puertas[i][y_afuera], Puertas[i][z_afuera]);
				return 1;
			}
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	//

	case DIALOG_REGISTRO:
	{
      if(response)
		{
			new contra[128];
			SCM(playerid, VERDECLARO, "¡Bien!{ffffff} Continuemos con el registro.");
			ShowPlayerDialog(playerid, DIALOG_GENERO, DIALOG_STYLE_MSGBOX, "Genero", "Seleccione su genero.", "Masculino", "Femenino");
			format(contra,sizeof(contra),"%s",inputtext);
			Jugador[playerid][Contra] = contra;
		}
		else
		{
			Kick(playerid);
		}
	}
    //
	case DIALOG_GENERO:
	{
		if(response)
		{
			Jugador[playerid][Genero] = 0;
			Jugador[playerid][Ropa] = 46;
			SCM(playerid,-1,"Has seleccionado {FFFF00}masculino{FFFFFF}.");
			ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Edad", "Ingrese su edad\n\nMinimo 18 - Maximo 90.", "Continuar", "Cancelar");
		}
		else
		{
			Jugador[playerid][Genero] = 1;
			Jugador[playerid][Ropa] = 12;
			SCM(playerid,-1,"Has seleccionado {FFFF00}femenino{FFFFFF}.");
			ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Edad", "Ingrese su edad\n\nMinimo 18 - Maximo 90.", "Continuar", "Cancelar");
		}
	}
	//
	case DIALOG_EDAD:
	{
	   if(response)
		{
			if(strval(inputtext) < 18 || strval(inputtext) > 100) return ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "Edad", "Ingrese su edad\n\n{FF0000}Minimo 18 - Maximo 90.", "Continuar", "Cancelar");
			Jugador[playerid][Edad] = strval(inputtext);
			SetSpawnInfo(
			    playerid,
			    0,
			    Jugador[playerid][Ropa],
			    -1861.7253,
			    71.0807,
			    1055.1963,
			    0.0,
			    0,0,0,0,0,0
			);
			SetPlayerInterior(playerid, 14);
			SetPlayerFacingAngle(playerid, 180.0);
			SetPVarInt(playerid, "PuedeIngresar", 1);
			SpawnPlayer(playerid);
			CrearCuenta(playerid);
	   }
		else
		{
			Kick(playerid);
		}
	}
	//
	case DIALOG_INGRESO:
	{
      if(response)
		{
			new query[520];
			mysql_format(MySQL,query,sizeof(query),"SELECT * FROM `cuentas` WHERE `Nombre`='%s' AND `Contra`='%s'",NombreJugador(playerid),inputtext);
			mysql_pquery(MySQL, query, "IngresoJugador","d", playerid);
		}
		else
		{
			Kick(playerid);
		}
	}
	//
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public VerificarUsuario(playerid)
{
	new Rows;
	Rows = cache_get_row_count();
	if(!Rows)
	{
   		CamaraInicio(playerid);
		ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_INPUT, "Registro", "Bienvenido\n\nIngrese una contraseña para registrarse.", "Registrar", "Cancelar");
	}
	else
	{
		CamaraInicio(playerid);
		ShowPlayerDialog(playerid, DIALOG_INGRESO, DIALOG_STYLE_INPUT, "Ingreso", "Bienvenido\n\nIngrese su contraseña para ingresar.", "Continuar", "Cancelar");
	}
	return 1;
}

stock CamaraInicio(playerid)
{
	SetPlayerCameraPos(playerid, 1533.2587, -1763.7717, 73.6204);
	SetPlayerCameraLookAt(playerid, 1532.9288, -1762.8286, 73.0504);
	SetPlayerPos(playerid,1513.4531, -1782.2853, 68.0610);
	TogglePlayerControllable(playerid,0);
	return 1;
}

stock NombreJugador(playerid)
{
	new nombre[MAX_PLAYER_NAME];
	GetPlayerName(playerid, nombre, sizeof(nombre));
	return nombre;
}

public CrearCuenta(playerid)
{
	new query[520],aviso[125];
	mysql_format(MySQL, query, sizeof(query), "INSERT INTO `cuentas`(`Nombre`, `Contra`, `Ropa`, `X`, `Y`, `Z`, `Genero`, `Vida`, `Dinero`, `Coins`) VALUES ('%s','%s','%i','1484.1082', '-1668.4976', '14.9159','%i','100','5000')",
	NombreJugador(playerid),
	Jugador[playerid][Contra],
	Jugador[playerid][Ropa],
	Jugador[playerid][Genero]);
	mysql_query(MySQL, query);

	SCM(playerid, -1, "¡Felicidades! Tu registro ha sido completado con éxito. ¡Comienza la aventura!");
	SCM(playerid, -1, "¡Bienvenido al servidor! Prepárate para vivir momentos épicos y divertidos. ¡Disfruta tu estadía!");
	SCM(playerid, -1, "Como bienvenida, recibiste un bono especial en tu cuenta. ¡Aprovecha al máximo tu inicio!");

	format(aviso,sizeof(aviso),"Cuenta creada: %s - Edad: %d - Genero: %d", NombreJugador(playerid), Jugador[playerid][Edad], Jugador[playerid][Genero]);
	print(aviso);
	return 1;
}

public IngresoJugador(playerid)
{
	if(cache_get_row_count() == 0)
	{
		ShowPlayerDialog(playerid, DIALOG_INGRESO, DIALOG_STYLE_INPUT, "Ingreso", "¡Error!\n\nLa contraseña no es correcta.", "Continuar", "Cancelar");
	}
	else
	{
		Jugador[playerid][Ropa] = cache_get_row_int(0, 3);
		Jugador[playerid][X] = cache_get_row_float(0, 4);
		Jugador[playerid][Y] = cache_get_row_float(0, 5);
		Jugador[playerid][Z] = cache_get_row_float(0, 6);
		Jugador[playerid][Genero] = cache_get_row_int(0, 7);
		Jugador[playerid][Vida] = cache_get_row_float(0, 8);
		Jugador[playerid][Chaleco] = cache_get_row_float(0, 9);
		Jugador[playerid][Muertes] = cache_get_row_int(0, 10);
		Jugador[playerid][Asesinatos] = cache_get_row_int(0, 11);
		Jugador[playerid][Faccion] = cache_get_row_int(0, 12);
		Jugador[playerid][Rango] = cache_get_row_int(0, 13);
		Jugador[playerid][Trabajo] = cache_get_row_int(0, 14);
		Jugador[playerid][Dinero] = cache_get_row_int(0, 15);
		Jugador[playerid][Int] = cache_get_row_int(0, 16);
		Jugador[playerid][VW] = cache_get_row_int(0, 17);
		Jugador[playerid][Edad] = cache_get_row_int(0, 18);
		Jugador[playerid][Coins] = cache_get_row_int(0, 19);
		Jugador[playerid][PuntosRol] = cache_get_row_int(0, 20);
		Jugador[playerid][Admin] = cache_get_row_int(0, 21);
		SetPVarInt(playerid, "PuedeIngresar", 1);
		IngresarJugador(playerid);
	}
	return 1;
}

public IngresarJugador(playerid)
{

	SetSpawnInfo(playerid, 0, Jugador[playerid][Ropa], Jugador[playerid][X],Jugador[playerid][Y],Jugador[playerid][Z], 0.0000, 0,0,0,0,0,0);
	SpawnPlayer(playerid);

	SetPlayerHealth(playerid,Jugador[playerid][Vida]);
	SetPlayerArmour(playerid,Jugador[playerid][Chaleco]);
	GivePlayerMoney(playerid,Jugador[playerid][Dinero]);
	SetPlayerVirtualWorld(playerid,Jugador[playerid][VW]);
	SetPlayerInterior(playerid,Jugador[playerid][Int]);
	SetPlayerSkin(playerid,Jugador[playerid][Ropa]);

	for(new i = 0; i < 20; i++)
	{
		SendClientMessage(playerid, -1, " ");
	}
	new string[128];
	SendClientMessage(playerid, -1, "Bienvenido a Mundo Roleplay - Versión V1.0");
	format(string, sizeof(string), "Bienvenido a la ciudad de Los Santos, %s.", NombreJugador(playerid));
	SendClientMessage(playerid, -1, string);
	return 1;
}

public GuardarJugador(playerid)
{
	new query[520],Float:jX,Float:jY,Float:jZ,Float:hp,Float:chale,pVW,pInt;
	GetPlayerPos(playerid, jX, jY, jZ);
	GetPlayerHealth(playerid,hp);
	GetPlayerArmour(playerid,chale);
	Jugador[playerid][VW] = GetPlayerVirtualWorld(playerid);
	Jugador[playerid][Int] = GetPlayerInterior(playerid);
	pVW = GetPlayerVirtualWorld(playerid);
	pInt = GetPlayerInterior(playerid);
	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `Ropa`='%i',`X`='%f',`Y`='%f',`Z`='%f',`Genero`='%i',`Vida`='%f',`Chaleco`='%f',`Muertes`='%i',`Asesinatos`='%i' WHERE `Nombre`='%s'",
	Jugador[playerid][Ropa],
	jX,
	jY,
	jZ,
	Jugador[playerid][Genero],
	hp,
	chale,
	Jugador[playerid][Muertes],
	Jugador[playerid][Asesinatos],
	NombreJugador(playerid));
	mysql_query(MySQL, query);
	//
	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `Edad`='%i', `Faccion`='%i', `Rango`='%i', `Trabajo`='%i', `Dinero`='%i' WHERE `Nombre`='%s'",
	Jugador[playerid][Edad],
	Jugador[playerid][Faccion],
	Jugador[playerid][Rango],
	Jugador[playerid][Trabajo],
	Jugador[playerid][Dinero],
	NombreJugador(playerid));
	mysql_query(MySQL, query);

	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `VW`='%i', `Interior`='%i' WHERE `Nombre`='%s'",
	pVW,
	pInt,
	NombreJugador(playerid));
	mysql_query(MySQL, query);

	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `Coins`='%i' WHERE `Nombre`='%s'",
	Jugador[playerid][Coins],
	NombreJugador(playerid));
	mysql_query(MySQL, query);

	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `PuntosRol`='%i' WHERE `Nombre`='%s'",
   Jugador[playerid][PuntosRol],
   NombreJugador(playerid));
  	mysql_query(MySQL, query);

	mysql_format(MySQL, query, sizeof(query), "UPDATE `cuentas` SET `Admin`='%i' WHERE `Nombre`='%s'",
	Jugador[playerid][Admin],
	NombreJugador(playerid));
	mysql_query(MySQL, query);
	return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	switch(errorid)
	{
		case CR_SERVER_GONE_ERROR:
		{
			printf("Conexion perdida..");
			mysql_reconnect(connectionHandle);
		}
		case ER_SYNTAX_ERROR:
		{
			printf("Error en el sintaxis de la consulta: %s",query);
		}
	}
	return 1;
}

stock MensajeFaccion(fid, color, mensaje[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	if(Jugador[i][Faccion] == fid)
	{
		SCM(i,color,mensaje);
		}
	}
	return 1;
}









//// CHAT RP ////
public OnPlayerText(playerid, text[])
{
    // Chat IC (roleplay)
    new string[144], nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    format(string, sizeof(string), "%s dice: %s", nombre, text);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
        {
            // Solo los que están cerca (20 metros)
            if(GetPlayerDistanceFromPoint(i, Jugador[playerid][X], Jugador[playerid][Y], Jugador[playerid][Z]) < 20.0)
            {
                SendClientMessage(i, 0xFFFFFFAA, string);
            }
        }
    }
    return 0; // Bloquea el mensaje global default
}




CMD:susurrar(playerid, params[])
{
    new id, mensaje[128];
    if(sscanf(params, "us[128]", id, mensaje)) return SCM(playerid, -1, "Uso: /susurrar [id] [mensaje]");
    if(!IsPlayerConnected(id) || id == playerid) return SCM(playerid, -1, "Jugador no válido.");
    // Verifica distancia (3 metros)
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);
    if(GetPlayerDistanceFromPoint(id, x, y, z) > 3.0) return SCM(playerid, -1, "El jugador está demasiado lejos para susurrar.");
    new nombre1[MAX_PLAYER_NAME], nombre2[MAX_PLAYER_NAME], str[144];
    GetPlayerName(playerid, nombre1, sizeof(nombre1));
    GetPlayerName(id, nombre2, sizeof(nombre2));
    format(str, sizeof(str), "%s susurra a %s: %s", nombre1, nombre2, mensaje);
    SCM(id, 0xC2A2DAFF, str);
    SCM(playerid, 0xC2A2DAFF, str);
    return 1;
}

CMD:b(playerid, params[])
{
    if(isnull(params)) return SCM(playerid, -1, "Uso: /b [mensaje]");
    new string[144], nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    format(string, sizeof(string), "(( %s: %s ))", nombre, params);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
        {
            if(GetPlayerDistanceFromPoint(i, Jugador[playerid][X], Jugador[playerid][Y], Jugador[playerid][Z]) < 20.0)
            {
                SCM(i, 0xAAAAAAFF, string);
            }
        }
    }
    return 1;
}

CMD:g(playerid, params[])
{
    if(isnull(params)) return SCM(playerid, -1, "Uso: /g [mensaje]");
    new string[144], nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    format(string, sizeof(string), "[GRITA] %s: %s", nombre, params);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
        {
            if(GetPlayerDistanceFromPoint(i, Jugador[playerid][X], Jugador[playerid][Y], Jugador[playerid][Z]) < 40.0)
            {
                SCM(i, 0xFFDD00FF, string);
            }
        }
    }
    return 1;
}

CMD:me(playerid, params[])
{
    if(isnull(params)) return SCM(playerid, -1, "Uso: /me [acción]");
    new string[144], nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    format(string, sizeof(string), "* %s %s", nombre, params);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
        {
            if(GetPlayerDistanceFromPoint(i, Jugador[playerid][X], Jugador[playerid][Y], Jugador[playerid][Z]) < 20.0)
            {
                SCM(i, 0xC2A2DAFF, string);
            }
        }
    }
    return 1;
}

CMD:do(playerid, params[])
{
    if(isnull(params)) return SCM(playerid, -1, "Uso: /do [descripción]");
    new string[144], nombre[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    format(string, sizeof(string), "(( %s: %s ))", nombre, params);
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i) && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
        {
            if(GetPlayerDistanceFromPoint(i, Jugador[playerid][X], Jugador[playerid][Y], Jugador[playerid][Z]) < 20.0)
            {
                SCM(i, 0xC2A2DAFF, string);
            }
        }
    }
    return 1;
}

CMD:fix(playerid, params[])
{
    if(Jugador[playerid][Coins] < 1)
        return SCM(playerid, 0xFF0000FF, "Necesitas tener coins para usar este comando.");

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == 0)
        return SCM(playerid, 0xFF0000FF, "¡Debes estar dentro de un vehículo para repararlo!");

    RepairVehicle(vehicleid);
    SCM(playerid, 0x00FF00FF, "¡Tu vehículo ha sido reparado usando coins!");
    return 1;
}


CMD:sa(playerid, params[])
{
    new precio = 5; // Precio de la reparación en coins

    if(Jugador[playerid][Coins] < precio)
        return SCM(playerid, 0xFF0000FF, "Necesitas tener al menos 5 coins para reparar tu vehículo.");

    new vehicleid = GetPlayerVehicleID(playerid);
    if(vehicleid == 0)
        return SCM(playerid, 0xFF0000FF, "¡Debes estar dentro de un vehículo para repararlo!");

    // Descontar los coins
    Jugador[playerid][Coins] -= precio;

    // Reparar el vehículo
    RepairVehicle(vehicleid);

    SCM(playerid, 0x00FF00FF, "¡Tu vehículo ha sido reparado usando coins!");

    return 1;
}

///// STAFF //////


CMD:setlevel(playerid, params[])
{
    if(Jugador[playerid][Admin] < 5) return SCM(playerid, 0xFF0000FF, "No tienes permisos para usar este comando.");
    new id, nivel;
    if(sscanf(params, "ui", id, nivel)) return SCM(playerid, -1, "Uso: /setlevel [id] [nivel]");
    Jugador[id][Admin] = nivel;
    GuardarJugador(id); // Guarda los puntos de rol en la base de datos
    SCM(id, 0x00FF00FF, "¡Ahora eres admin!");
    return 1;
}

CMD:kick(playerid, params[])
{
    if(Jugador[playerid][Admin] < 1) return SCM(playerid, 0xFF0000FF, "No tienes permisos para usar este comando.");
    new id;
    if(sscanf(params, "u", id)) return SCM(playerid, -1, "Uso: /kick [id]");
    Kick(id);
    return 1;
}

CMD:darcoinooc(playerid, params[])
{
    if(Jugador[playerid][Admin] < 5) return SCM(playerid, 0xFF0000FF, "No tienes permisos.");
    new id, cantidad;
    if(sscanf(params, "ui", id, cantidad)) return SCM(playerid, -1, "Uso: /darcoinooc [id] [cantidad]");
    Jugador[id][Coins] += cantidad;
    GuardarJugador(id); // Guarda los puntos de rol en la base de datos
    new str[64];
    format(str, sizeof(str), "Te han dado %d coins.", cantidad);
    SCM(id, 0x00FF00FF, str);
    return 1;
}

CMD:darpuntosrolooc(playerid, params[])
{
    if(Jugador[playerid][Admin] < 5) return SCM(playerid, 0xFF0000FF, "No tienes permisos para usar este comando.");
    new id, cantidad;
    if(sscanf(params, "ui", id, cantidad)) return SCM(playerid, -1, "Uso: /darpuntosrolooc [id] [cantidad]");
    if(!IsPlayerConnected(id)) return SCM(playerid, -1, "Jugador no válido.");
    Jugador[id][PuntosRol] += cantidad;
    GuardarJugador(id); // Guarda los puntos de rol en la base de datos
    new str[64];
    format(str, sizeof(str), "Le diste %d puntos de rol a %s.", cantidad, NombreJugador(id));
    SCM(playerid, 0x00FF00FF, str);
    format(str, sizeof(str), "Un admin te dio %d puntos de rol.", cantidad);
    SCM(id, 0x00FF00FF, str);
    return 1;
}

CMD:darmoneyooc(playerid, params[])
{
    if(Jugador[playerid][Admin] < 5) return SCM(playerid, 0xFF0000FF, "No tienes permisos para usar este comando.");
    new id, cantidad;
    if(sscanf(params, "ui", id, cantidad)) return SCM(playerid, -1, "Uso: /darmoneyooc [id] [cantidad]");
    if(!IsPlayerConnected(id)) return SCM(playerid, -1, "Jugador no válido.");
    Jugador[id][Dinero] += cantidad; // Suma el dinero en la variable del jugador
    GivePlayerMoney(id, cantidad);   // Suma el dinero visualmente en el juego
    GuardarJugador(id);              // Guarda el dinero en la base de datos
    new str[64];
    format(str, sizeof(str), "Le diste $%d a %s.", cantidad, NombreJugador(id));
    SCM(playerid, 0x00FF00FF, str);
    format(str, sizeof(str), "Un admin te dio $%d.", cantidad);
    SCM(id, 0x00FF00FF, str);
    return 1;
}