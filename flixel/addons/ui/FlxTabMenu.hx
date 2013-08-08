package flixel.addons.ui;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * @author Lars Doucet
 */

class FlxTabMenu extends FlxGroupX implements IEventGetter implements IResizable
{

	/***Event Handling***/
	
	public function getEvent(id:String, sender:Dynamic, data:Dynamic):Void {
		//not yet implemented
	}
	
	public function getRequest(id:String, sender:Dynamic, data:Dynamic):Dynamic {
		//not yet implemented
		return null;
	}	
	
	/**For IResizable**/
	
	public function get_width():Float {
		return _back.width;
	}
	
	public function get_height():Float {
		var fbt = getFirstTab();
		if (fbt != null) {
			return (_back.y + _back.height) - fbt.y;
		}		
		return _back.height;
	}
	
	public function resize(W:Float, H:Float):Void {
		var ir:IResizable;
		if (Std.is(_back, IResizable)) {
			ir = cast _back;
			var fbt = getFirstTab();
			if(fbt != null){
				ir.resize(W, H-fbt.get_height());
			}else {
				ir.resize(W, H);
			}
		}
		distributeTabs();
	}
	
	private inline function getFirstTab():FlxButtonToggle{
		var _the_tab:FlxButtonToggle = null;
		if(_tabs != null && _tabs.length > 0){
			_the_tab = _tabs[0];
		}
		return _the_tab;
	}
	
	/***PUBLIC***/
	
	public function new(back_:FlxSprite,tabs_:Array<FlxButtonToggle>,stretch_tabs:Bool=false) 
	{
		super();		
		_back = back_;
		add(_back);
		
		var offset_y:Float = 0;
		
		_tabs = tabs_;
		_stretch_tabs = stretch_tabs;
				
		for (tab in _tabs) {
			add(tab);
			tab.Callback = onClickTab;
		}
		
		distributeTabs();
				
		_tab_groups = new Array<FlxGroupX>();
	}
	
	private function distributeTabs():Void {
		var xx:Float = 0;
		
		var tab_width:Float = 0;
		
		if (_stretch_tabs) {
			tab_width = _back.width / _tabs.length;
		}
		
		for (tab in _tabs) {
			
			tab.x = xx;			
			tab.y = -(tab.btn_normal.height - 2);			
			
			if (_stretch_tabs) {
				tab.resize(tab_width, tab.get_height());
				xx += tab_width;	
				//this is to avoid small rounding errors
				//(this guarantees we'll use up the whole space)
			}else{
				xx += tab.btn_normal.width;
			}
		}
	}
	
	public override function destroy():Void {
		super.destroy();
		U.clearArray(_tab_groups);
		U.clearArray(_tabs);
		_back = null;
		_tabs = null;
		_tab_groups = null;
	}

	public function addGroup(g:FlxGroupX):Void {
		if (g == this) {
			return;			//DO NOT ADD A GROUP TO ITSELF
		}
		
		if(!hasThis(g)){	//ONLY ADD IF IT DOESN'T EXIST
			add(g);
			_tab_groups.push(g);
		}
		
		_showOnlyGroup("");
	}
	
	public function showTabInt(i:Int):Void {
		if(_tabs != null && _tabs.length > i){
			var _tab:FlxButtonToggle = _tabs[i];
			var id:String = _tab.id;
			onClickTab([id]);
		}
	}
	
	public function onClickTab(Params:Dynamic):Void {
		var id:String = "";
		if (Std.is(Params,Array)) {
			if (Std.is(Params[0], String)) {
				id = Params[0];
			}
		}
		
		if (id == "") return;
		
		for (tab in _tabs) {
			if (tab.id == id) {
				if(!tab.toggle){
					tab.toggle = true;					
				}
			}else {
				tab.toggle = false;
			}
		}
		
		_showOnlyGroup(id);
	}
		
	/***PRIVATE***/
	
	private var _back:FlxSprite;
	private var _tabs:Array<FlxButtonToggle>;
	private var _tab_groups:Array<FlxGroupX>;
	private var _stretch_tabs:Bool = false;
	
	private function _showOnlyGroup(id:String):Void {
		for (group in _tab_groups) {
			if (group.str_id == id) {
				group.visible = group.active = true;
			}else {
				group.visible = group.active = false;
			}
		}
	}
}