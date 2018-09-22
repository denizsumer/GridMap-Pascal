unit baseInitialise;

interface
uses baseTypes, SwinGame, sgTypes, sgPhysics;

function CalculateBaseSet(var mapSize: Integer): BaseSet;

function CalculateCamPos(var base: BaseSet): Position;

procedure LoadResources();

procedure InitialiseGame(var game: GameData);


implementation

const
	GRIDWIDTH = 150;
	GRIDHEIGHT = 75;
	GRIDHALF = 37.5;

function CalculateBaseSet(var mapSize: Integer): BaseSet;
begin
	///CALCULATES MAPS HEIGH, WIDTH AND MAPDIVIDER (COEFFICIENT FOR DETERMINING ROW AND COLUMN NO)///
	result.mapSize := mapSize;
	result.MapDivider := Round(sqrt(mapSize));
	result.MapWidth := result.MapDivider * GRIDWIDTH;
	result.MapHeight := result.MapDivider * GRIDHEIGHT;
end;

function CalculateCamPos(var base: BaseSet): Position;
begin
	///CALCULATES INITIAL CAMERA POSITION///
	result.x := (ScreenWidth() / -2) + GRIDHEIGHT;
	result.y := (base.mapHeight / 2) - (ScreenHeight() / 2);
end;

procedure LoadResources();
begin
	LoadBitmapNamed('radar', 'radar.png');
	LoadBitmapNamed('base', 'base.png');
	LoadBitmapNamed('selectedBase', 'sel_base.png');
	LoadBitmapNamed('cursorBase', 'cursor_base.png');
end;

procedure InitialiseGame(var game: GameData);
var
	mapSizeSelect: Integer;
begin
	LoadResources();
	game.devMode := false;
	OpenGraphicsWindow('Base', 1280, 720);
	game.zoom := 10;
	mapSizeSelect := 5;
	case (mapSizeSelect) of
		1 : game.base.mapSize := 200;
		2 : game.base.mapSize := 450;
		3 :	game.base.mapSize := 1800;
		4 : game.base.mapSize := 3200;
		5 : game.base.mapSize := 100;
	end;
	game.base := CalculateBaseSet(game.base.mapSize);
	game.campos := CalculateCamPos(game.base);
	SetLength(game.base.grids, game.base.mapSize);
	game.base.firstSelected := nil;
	game.base.lastSelected := nil;
end;

end.