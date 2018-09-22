unit baseInput;

interface
uses SwinGame, sgTypes, sgPhysics, sysUtils, baseTypes;

procedure CheckCursorOnGrid(var grid: Grid; var base: BaseSet);

procedure MoveBase(var campos: Position; direction: Char; game: GameData);

procedure DevMode(var game: GameData);

procedure UserInputs(var game: GameData);


implementation

const
	GRIDWIDTH = 150;
	GRIDHEIGHT = 75;
	GRIDHALF = 37.5;

procedure CheckCursorOnGrid(var grid: Grid; var base: BaseSet);
var
	mDistX, mDistY: Single;
	maxPosDistYAxis, maxNegDistYAxis: Single;
	///VARIABLES TO DETERMINE SELECTION DIRECTION///
	rowsbwt, colsbwt: Integer;
begin
	///DISTANCE OF MOUSE CURSOR FROM THE CENTER OF GRID///
	mDistX := MouseX() - (grid.pos.x + (gridWidth / 2));
	mDistY := MouseY() - (grid.pos.y + (gridHeight / 2));

	///MAX DISTANCE OF CURSOR ON Y AXIS FROM CENTERLINE AS PER ISOMETRIC SHAPE///
	maxPosDistYAxis := (abs(mDistX) - gridHeight ) / -2;
	maxNegDistYAxis := (abs(mDistX) - gridHeight ) / 2;

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
	blnksec := 125; ///BLANK AREA LEFT ON THE EDGE OF THE BASE///


	if (MouseX() > blndsec) and (MouseX() < ScreenWidth - blndsec) and (MouseY() > blndsec) and (MouseY() < ScreenHeight() - blndsec) then
	begin
		/// L = LEFT // R = RIGHT // U = UP // D = DOWN ///
		if (direction = 'L') and (campos.x > (game.base.mapWidth / -2) + GRIDHEIGHT - blnksec) then campos.x := campos.x - movespd;
		if (direction = 'R') and (campos.x < (game.base.mapWidth / 2) - ScreenWidth() + GRIDHEIGHT + blnksec) then campos.x := campos.x + movespd;
		if (direction = 'U') and (campos.y > -blnksec) then campos.y := campos.y - movespd;
		if (direction = 'D') and (campos.y < game.base.mapHeight - ScreenHeight() + blnksec) then campos.y := campos.y + movespd;
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
		DrawText('Zoom : x ' + FloattoStr(game.zoom/10), colorRed, 'arial.ttf', 14, 15, 60);

		DrawText('Map Size : ' + FloattoStr(game.base.mapSize), colorRed, 'arial.ttf', 14, 15, 90);
		DrawText('CamPos X : ' + FloattoStr(game.campos.x), colorRed, 'arial.ttf', 14, 15, 105);
		DrawText('CamPos Y : ' + FloattoStr(game.campos.y), colorRed, 'arial.ttf', 14, 15, 120);

		DrawText('Radar X : ' + FloattoStr(game.radar.x), colorRed, 'arial.ttf', 14, 15, 150);
		DrawText('Radar Y : ' + FloattoStr(game.radar.y), colorRed, 'arial.ttf', 14, 15, 165);

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
		CheckCursorOnGrid(game.base.grids[i], game.base);
		if MouseClicked(RightButton) then game.base.grids[i].selected := false;
	end;
	///ZOOM IN & ZOOM OUT)///
	if KeyTyped(QKey) and (game.zoom < 80) then game.zoom := game.zoom * 2;
	if KeyTyped(EKey) and (game.zoom > 10) then game.zoom := Round(game.zoom / 2);
	///DEV MODE///
	if KeyDown(LeftCtrlKey) then if KeyTyped(QKey) then game.devMode := not (game.devMode);
end;

end.