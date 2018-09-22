//zoom in zoom out???
//swin splash
//worst game splash
//mouse cursors
//full screen and borderless option
//menu and exit button

program Basement;
uses SwinGame, sgTypes, sgPhysics, sysUtils;

type
	Position = record
		x, y: Single;
	end;
	
	Grid = record
		Id: Integer;
		Row: Integer;
		Column: Integer;
		Pos: Position;
		Loaded: Boolean;
		OnCursor: Boolean;
		Selected: Boolean;
	end;

	BaseSet = record
		Grids: Array of Grid;
		FirstSelected: ^Grid;
		LastSelected: ^Grid;
		MapSize: Integer;
		MapDivider: Integer;
		MapWidth: Integer;
		MapHeight: Integer;

	end;

	GameData = record
		Base: BaseSet;
		CamPos: Position;
		Radar: Position;
		Zoom: Integer;
		DevMode: Boolean;
	end;

const
	GRIDWIDTH = 150;
	GRIDHEIGHT = 75;

function Zoomed(const val: Integer; var zoom: Integer): Integer;
begin
	result := val * zoom;
end;

function CalculateBaseSet(var mapSize: Integer; var game: GameData): BaseSet;
begin
	///CALCULATES MAPS HEIGH, WIDTH AND MAPDIVIDER (COEFFICIENT FOR DETERMINING ROW AND COLUMN NO)///
	result.mapSize := mapSize;
	result.MapDivider := Round(sqrt(mapSize));
	result.MapWidth := result.MapDivider * Zoomed(GRIDWIDTH, game.zoom);
	result.MapHeight := result.MapDivider * Zoomed(GRIDHEIGHT, game.zoom);
end;

function CalculateCamPos(var base: BaseSet; var game: GameData): Position;
begin
	///CALCULATES INITIAL CAMERA POSITION///
	result.x := (ScreenWidth() / -2) + Zoomed(GRIDHEIGHT, game.zoom);
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
	game.zoom := 1;
	mapSizeSelect := 1;
	case (mapSizeSelect) of
		1 : game.base.mapSize := 225;
		2 : game.base.mapSize := 400;
		3 :	game.base.mapSize := 900;
		4 : game.base.mapSize := 1600;
		5 : game.base.mapSize := 2500;
	end;
	game.base := CalculateBaseSet(game.base.mapSize, game);
	game.campos := CalculateCamPos(game.base, game);
	SetLength(game.base.grids, game.base.mapSize);
	game.base.firstSelected := nil;
	game.base.lastSelected := nil;
end;

procedure DrawRadar(var game: GameData);
var
	camposXToZero, camposYToZero: Single;
	mapRadarXRatio, mapRadarYRatio: Single;
	areaWidth, areaHeight: Single;
begin
	///CALCULATIONS TO MATCH MAPSIZE TO RADAR RATIO///
	areaWidth := (260 * ScreenWidth() / (game.base.mapWidth + 250)) / game.zoom;
	areaHeight := (135 * ScreenHeight() / (game.base.mapHeight + 250)) / game.zoom;
	camposXToZero := game.campos.x + (Zoomed(game.base.mapWidth, game.zoom) / 2) - Zoomed(GRIDHEIGHT, game.zoom) + 125;
	camposYToZero := game.campos.y + 125;
	mapRadarXRatio := (Zoomed(game.base.mapWidth, game.zoom) - ScreenWidth() + 250) / (260 - areaWidth);
	mapRadarYRatio := (Zoomed(game.base.mapHeight, game.zoom) - ScreenHeight() + 250) / (135 - areaHeight);

	///DRAWS SMALL SCALE MAP ON THE LEFT TOP///
	game.radar.x := 1000 + (camposXToZero / mapRadarXRatio);
	game.radar.y := 20 + (camposYToZero / mapRadarYRatio) ;
	DrawBitmap('radar', 1005, 25);
	DrawRectangle(colorRed, game.radar.x, game.radar.y, areaWidth, areaHeight);

	DrawText('Radar X : ' + FloattoStr(Round(game.radar.x)), colorRed, 'arial.ttf', 14, 15, 150);
	DrawText('Radar Y : ' + FloattoStr(Round(game.radar.y)), colorRed, 'arial.ttf', 14, 15, 165);

	DrawText('areaWidth : ' + FloattoStr(Round(areaWidth)), colorRed, 'arial.ttf', 14, 15, 180);
	DrawText('areaHeight : ' + FloattoStr(Round(areaHeight)), colorRed, 'arial.ttf', 14, 15, 195);

end;

procedure DrawGrid(var grid: Grid; var game: GameData);
begin
	grid.pos.x := (grid.column - grid.row) * Zoomed(GRIDHEIGHT, game.zoom) - game.campos.x;
	grid.pos.y := (grid.row + grid.column) * (Zoomed(GRIDHEIGHT, game.zoom) / 2) - Zoomed(GRIDHEIGHT, game.zoom) - game.campos.y;

	///DRAWS GRID BITMAPS FOR NORMAL, CURSOR ON IT AND SELECTED///
	if grid.selected = false then DrawBitmap('base', grid.pos.x, grid.pos.y, OptionScaleBmp(game.zoom, game.zoom));
	if grid.onCursor = true then DrawBitmap('cursorBase', grid.pos.x, grid.pos.y, OptionScaleBmp(game.zoom, game.zoom));
	if grid.selected = true then DrawBitmap('selectedBase', grid.pos.x, grid.pos.y, OptionScaleBmp(game.zoom, game.zoom));
end;

procedure DrawGame(game: GameData);
var
	i: Integer;
begin
	///DRAW GRIDS///
	for i := 0 to High(game.base.grids) do
	begin
		game.base.grids[i].id := i + 1 ;
		game.base.grids[i].row := trunc((game.base.grids[i].id -1) / game.base.MapDivider) + 1;
		game.base.grids[i].column := (game.base.grids[i].id mod game.base.MapDivider);
		if game.base.grids[i].column = 0 then game.base.grids[i].column := game.base.MapDivider;
		DrawGrid(game.base.grids[i], game);
	end;
	///DRAW RADAR///
	DrawRadar(game);
end;

procedure CheckCursorOnGrid(var grid: Grid; var base: BaseSet; var game: GameData);
var
	mDistX, mDistY: Single;
	maxPosDistYAxis, maxNegDistYAxis: Single;
	rowsbwt, colsbwt: Integer;	///VARIABLES TO DETERMINE SELECTION DIRECTION///
begin
	///DISTANCE OF MOUSE CURSOR FROM THE CENTER OF GRID///
	mDistX := MouseX() - (grid.pos.x + (GRIDWIDTH / 2));
	mDistY := MouseY() - (grid.pos.y + (GRIDHEIGHT / 2));

	///MAX DISTANCE OF CURSOR ON Y AXIS FROM CENTERLINE AS PER ISOMETRIC SHAPE///
	maxPosDistYAxis := (abs(mDistX) - Zoomed(GRIDHEIGHT, game.zoom)) / -2;
	maxNegDistYAxis := (abs(mDistX) - Zoomed(GRIDHEIGHT, game.zoom)) / 2;

	///HIGHLIGHTING GRID UNDER CURSOR AND DETERMINING THE FIRST SELECTED GRID///
	if (mDistY > maxNegDistYAxis) and (mDistY < maxPosDistYAxis) then grid.onCursor := true else grid.onCursor := false;
	if (mDistY > maxNegDistYAxis) and (mDistY < maxPosDistYAxis) and MouseUp(LeftButton) then base.firstSelected := @grid;
	if (mDistY > maxNegDistYAxis) and (mDistY < maxPosDistYAxis) and MouseUp(LeftButton) then base.lastSelected := nil;

	///SELECTING THE GRID AND DETERMINING THE LAST SELECTED GRID///
	if (mDistY > maxNegDistYAxis) and (mDistY < maxPosDistYAxis) and MouseDown(LeftButton) then grid.selected := true;
	if (mDistY > maxNegDistYAxis) and (mDistY < maxPosDistYAxis) and MouseDown(LeftButton) then base.lastSelected := @grid;
	
	///MULTIPLE GRID SELECTION///
	if (base.lastSelected = nil) = false then
	begin
		///VARIABLES TO DETERMINE SELECTION DIRECTION///
		rowsbwt := base.firstSelected^.row - base.lastSelected^.row;
		colsbwt := base.firstSelected^.column - base.lastSelected^.column;
		///DOWN & RIGHT SELECTION///
		if (rowsbwt <= 0) and (colsbwt <= 0) then
			if (grid.row >= base.firstSelected^.row) and (grid.row <= base.lastSelected^.row)
			and (grid.column >= base.firstSelected^.column) and (grid.column <= base.lastSelected^.column)
			then grid.selected := true
			else grid.selected := false;
		///DOWN & LEFT SELECTION///
		if (rowsbwt <= 0) and (colsbwt >= 0) then
			if (grid.row >= base.firstSelected^.row) and (grid.row <= base.lastSelected^.row)
			and (grid.column <= base.firstSelected^.column) and (grid.column >= base.lastSelected^.column)
			then grid.selected := true
			else grid.selected := false;
		///UP & RIGHT SELECTION///
		if (rowsbwt >= 0) and (colsbwt <= 0) then
			if (grid.row <= base.firstSelected^.row) and (grid.row >= base.lastSelected^.row)
			and (grid.column >= base.firstSelected^.column) and (grid.column <= base.lastSelected^.column)
			then grid.selected := true
			else grid.selected := false;
		///UP & LEFT SELECTION///
		if (rowsbwt >= 0) and (colsbwt >= 0) then
			if (grid.row <= base.firstSelected^.row) and (grid.row >= base.lastSelected^.row)
			and (grid.column <= base.firstSelected^.column) and (grid.column >= base.lastSelected^.column)
			then grid.selected := true
			else grid.selected := false;
	end;
end;

procedure MoveBase(var campos: Position; direction: Char; game: GameData);
var
	movespd, blndsec, Blnksec: Integer;
begin
	movespd := 5; ///BASE MOVE SPEED///
	blndsec := 2; ///BLIND SECTOR FOR MOUSE CURSOR ON THE WINDOW EDGES///
	blnksec := 125 * game.zoom; ///BLANK AREA LEFT ON THE EDGE OF THE BASE///

	if (MouseX() > blndsec) and (MouseX() < ScreenWidth - blndsec) and (MouseY() > blndsec) and (MouseY() < ScreenHeight() - blndsec) then
	begin
		/// L = LEFT // R = RIGHT // U = UP // D = DOWN ///
		if (direction = 'L') and (campos.x > (Zoomed(game.base.mapWidth, game.zoom) / -2) + GRIDHEIGHT - blnksec) then campos.x := campos.x - movespd;
		if (direction = 'R') and (campos.x < (Zoomed(game.base.mapWidth, game.zoom) / 2) - ScreenWidth() + GRIDHEIGHT + blnksec) then campos.x := campos.x + movespd;
		if (direction = 'U') and (campos.y > -blnksec) then campos.y := campos.y - movespd;
		if (direction = 'D') and (campos.y < Zoomed(game.base.mapHeight, game.zoom) - ScreenHeight() + blnksec) then campos.y := campos.y + movespd;
	end;
end;

procedure DevMode(var game: GameData);
var
	i: Integer;
begin
	if game.devMode = true then
	begin
		DrawText('FPS : ' + FloatToStr(GetFramerate()), colorRed, 'arial.ttf', 14, 15, 15);
		DrawText('Mouse X : ' + FloattoStr(MouseX()), colorRed, 'arial.ttf', 14, 15, 30);
		DrawText('Mouse Y : ' + FloattoStr(MouseY()), colorRed, 'arial.ttf', 14, 15, 45);
		DrawText('Zoom : x ' + FloattoStr(game.zoom), colorRed, 'arial.ttf', 14, 15, 60);

		DrawText('Map Size : ' + FloattoStr(game.base.mapSize), colorRed, 'arial.ttf', 14, 15, 90);
		DrawText('CamPos X : ' + FloattoStr(game.campos.x), colorRed, 'arial.ttf', 14, 15, 105);
		DrawText('CamPos Y : ' + FloattoStr(game.campos.y), colorRed, 'arial.ttf', 14, 15, 120);

		//DrawText('Radar X : ' + FloattoStr(Round(game.radar.x)), colorRed, 'arial.ttf', 14, 15, 150);
		//DrawText('Radar Y : ' + FloattoStr(Round(game.radar.y)), colorRed, 'arial.ttf', 14, 15, 165);

		///SHOWS GRID.ID, GRID.ROW AND GRID.COLUMN FOR EACH GRID. REDUCES FPS///
		if Keydown(AltKey) then
		begin
			for i := 0 to High(game.base.grids) do
			begin
			DrawText('base id: ' + FloatToStr(game.base.grids[i].id), colorWhite, 'arial.ttf', 12, game.base.grids[i].pos.x+40, game.base.grids[i].pos.y+20);
			DrawText('row: ' + FloatToStr(game.base.grids[i].row) + 'clmn: ' + FloattoStr(game.base.grids[i].column), colorWhite, 'arial.ttf', 12, game.base.grids[i].pos.x+38, game.base.grids[i].pos.y+35);
			end;
		end;
		
		///SHOWS FIRST SELECTED AND LAST SELECTED GRID POINTERS///
		if (game.base.firstSelected = nil) = false then
		DrawText('first', colorRed, 'arial.ttf', 14, game.base.firstSelected^.pos.x, game.base.firstSelected^.pos.y);
		if (game.base.lastSelected = nil) = false then
		DrawText('last', colorRed, 'arial.ttf', 14, game.base.lastSelected^.pos.x, game.base.lastSelected^.pos.y);

	end;
end;

procedure UserInputs(var game: GameData);
var
	normSpdLimit, fastSpdLimit: Integer;
	i: Integer;
begin
	///BOUNDRIES FROM EDGES FOR MOVING MAP IN NORMAL SPEED AND DOUBLE SPEED///
	normSpdLimit := 50;
	fastSpdLimit := 25;
	/// L = LEFT // R = RIGHT // U = UP // D = DOWN ///
	///NORMAL SPEED MAP MOVE///
	if MouseX() < normSpdLimit then MoveBase(game.campos, 'L', game);
	if MouseX() > ScreenWidth() - normSpdLimit then MoveBase(game.campos, 'R', game);
	if MouseY() < normSpdLimit then MoveBase(game.campos, 'U', game);
	if MouseY() > ScreenHeight() - normSpdLimit then MoveBase(game.campos, 'D', game);
	///DOUBLE SPEED MAP MOVE///
	if MouseX() < fastSpdLimit then MoveBase(game.campos, 'L', game);
	if MouseX() > ScreenWidth() - fastSpdLimit then MoveBase(game.campos, 'R', game);
	if MouseY() < fastSpdLimit then MoveBase(game.campos, 'U', game);
	if MouseY() > ScreenHeight() - fastSpdLimit then MoveBase(game.campos, 'D', game);
	///GRID SELECTION AND HIGHLIGHTING///
	for i := 0 to High(game.base.grids) do
	begin
		CheckCursorOnGrid(game.base.grids[i], game.base, game);
		if MouseClicked(RightButton) then game.base.grids[i].selected := false;
	end;
	///ZOOM IN & ZOOM OUT)///
	if KeyTyped(QKey) and (game.zoom < 8) then
	begin
		game.zoom := Round(game.zoom * 2);
		game.CamPos.x := (game.camPos.x * 2) + (ScreenWidth()/4) + 245;
		game.camPos.y := (game.camPos.y * 2) + (ScreenHeight()/4) + 140;
	end;
	if KeyTyped(EKey) and (game.zoom > 1) then
	begin
		game.zoom := Round(game.zoom / 2);
		game.CamPos.x := (game.camPos.x - 245 - (ScreenWidth()/4)) / 2;
		game.camPos.y := (game.camPos.y - 140 - (ScreenHeight()/4)) / 2;
	end;
	///DEV MODE///
	if KeyDown(LeftCtrlKey) then if KeyTyped(TabKey) then game.devMode := not (game.devMode);
	DevMode(game);

	DrawLine(ColorBlack, 0, ScreenHeight()/2, ScreenWidth(),ScreenHeight()/2);
	DrawLine(ColorBlack, ScreenWidth()/2, 0, ScreenWidth()/2, ScreenHeight());
end;

	//result.x := (ScreenWidth() / -2) + Zoomed(GRIDHEIGHT, game.zoom);
	//result.y := (base.mapHeight / 2) - (ScreenHeight() / 2);

procedure Main();
var
	game: GameData;
begin
	InitialiseGame(game);
	repeat
		ProcessEvents();
	 	RefreshScreen(60);
	 	ClearScreen(colorGreen);
	 	DrawGame(game);
	 	UserInputs(game);
	until WindowCloseRequested();
end;

begin
	Main();
end.
