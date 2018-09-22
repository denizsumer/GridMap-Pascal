unit baseTypes;

interface

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

implementation

initialization
begin

end;

end.