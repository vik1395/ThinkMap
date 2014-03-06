package mapviewer.block;

import mapviewer.block.Block.Face;
import mapviewer.block.BlockRegistry.BlockRegistrationEntry;
import mapviewer.logging.Logger;
import mapviewer.model.Model;

class BlockRegistry {
    public static var logger : Logger = new Logger('BlockRegistry');

    /// Whether the blocks have been registered yet
    private static var hasInit : Bool = false;
    /// A map of plugin to blocks name to blocks
    private static var blocks : Map<String, Map<String, BlockRegistrationEntry>> = new Map();

    /**
     * Returns a block by its name.
     *
     * The format of the name of 'plugin:block'. If the format
     * 'block' is used then the plugin is assumed to be 'minecraft'.
     *
     * If the block doesn't exist then the block 'webglmap:missing_block'
     * is returned.
     */
    public static function get(name : String) : Block {
        if (!hasInit) init();
        var plugin = "minecraft";
        var index : Int = 0;
        if ((index = name.indexOf(":")) != -1) {
            plugin = name.substring(0, index);
            name = name.substring(index + 1);
        }
        if (blocks[plugin] == null) return Blocks.MISSING_BLOCK;
        var ret : BlockRegistrationEntry = blocks[plugin][name];
        if (ret == null) return Blocks.MISSING_BLOCK;
        return ret.block;
    }

    /// A map of legacy blocks ids to blocks
    public static var legacyMap : Array<BlockEntry> = new Array();

    /**
     * Using the id and data from legacy block id system
     * this will look up the block and return the new system
     * version of the block.
     *
     * If the block doesn't exist then the block 'webglmap:missing_block'
     */
    public static function getByLegacy(id : Int, data : Int) : Block {
        if (id == 0) return Blocks.AIR;
        var val = legacyMap[id];
        if (val == null) return Blocks.MISSING_BLOCK;
        var reg = val.getBlock(data);
        if (reg == null) return Blocks.MISSING_BLOCK;
        return reg.block;
    }


    /**
     * Registers the block using the [name] and [plugin] (which defaults
     * to 'minecraft').
     *
     * This returns a builder BlockRegistrationEntry which can be used to
     * set properties before committing to the registry with 'build'
     */
    public static function registerBlock(name : String, block : Block,
                                         ?plugin : String = "minecraft") : BlockRegistrationEntry {
        if (!blocks.exists(plugin)) {
            blocks[plugin] = new Map();
        }
        if (blocks[plugin].exists(name)) {
            throw 'Tried to double register block $name';
        }
        var reg = new BlockRegistrationEntry(plugin, name, block);
		block.regBlock = reg;
        blocks[plugin][name] = reg;
        logger.info('Registed block: $reg');
        return reg;
    }

    /**
     * Register all blocks
     */
    public static function init() {
        if (hasInit) return;
        hasInit = true;
		
		// Vanilla blocks
		registerBlock("air", new Block().chainBlock()
			.renderable(false)
			.solid(false)
			.collidable(false)
			.ret())
			.legacyId(0).build();
		registerBlock("stone", new Block().chainBlock()
			.texture("stone").ret())
			.legacyId(1).build();
		registerBlock("grass", new BlockSidedTextures().chainBlockSidedTextures()
			.textures([
				"front" => "grass_side",
				"back" => "grass_side",
				"left" => "grass_side",
				"right" => "grass_side",
				"bottom" => "dirt",
				"top" => "grass_top"]).ret()
			.chainBlock()
			.colour(0xA7D389)
			.getColour(function(self : Block, face : Face) : Int {
				return face == Face.TOP ? self.colour : 0xFFFFFF;
			}).ret())
			.legacyId(2).build();
			
		// Dirt blocks
		{
			registerBlock("dirt", new Block().chainBlock()
				.texture("dirt").ret())
				.legacyId(3)
				.dataValue(0)
				.build();
			registerBlock("dirt_grassless", new Block().chainBlock()
				.texture("dirt").ret())
				.legacyId(3)
				.dataValue(1)
				.build();
			registerBlock("dirt_podzol", new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"front" => "dirt_podzol_side",
					"top" => "dirt_podzol_top",
					"bottom" => "dirt",
					"back" => "dirt_podzol_side",
					"left" => "dirt_podzol_side",
					"right" => "dirt_podzol_side"
				]).ret())
				.legacyId(3)
				.dataValue(2)
				.build();
		}
			
		registerBlock("cobblestone", new Block().chainBlock()
			.texture("cobblestone").ret())
			.legacyId(4).build();
			
		var temp = [
			"oak" => 0,
			"spruce" => 1,
			"birch" => 2,
			"jungle" => 3,
			"acacia" => 4
		];
		for (k in temp.keys()) {
			var v = temp[k];
			registerBlock('planks_$k', new Block().chainBlock()
				.texture('planks_$k').ret())
				.legacyId(5)
				.dataValue(v)
				.build();
			
			registerBlock('sapling_$k', new BlockCross().chainBlock()
				.texture('sapling_$k')
				.collidable(false)
				.solid(false).ret())
				.legacyId(6)
				.dataValue(v).build();
			registerBlock('sapling_${k}_ticked', new BlockCross().chainBlock()
				.texture('sapling_$k')
				.collidable(false)
				.solid(false).ret())
				.legacyId(6)
				.dataValue(v | 8).build();
				
			registerBlock('leaves_$k', new Block().chainBlock()
				.texture('leaves_$k')
				.solid(false)
				.allowSelf(true)
				.colour(0xA7D389)
				.forceColour(true).ret())
				.legacyId(18)
				.dataValue(v)
				.build();
		}
		// Big oak is odd...		
		registerBlock('planks_big_oak', new Block().chainBlock()
			.texture('planks_big_oak').ret())
			.legacyId(5)
			.dataValue(5)
			.build();
		
		registerBlock('sapling_roofed_oak', new BlockCross().chainBlock()
			.texture('sapling_roofed_oak')
			.collidable(false)
			.solid(false).ret())
			.legacyId(6)
			.dataValue(5).build();
		registerBlock('sapling_roofed_oak_ticked', new BlockCross().chainBlock()
			.texture('sapling_roofed_oak')
			.collidable(false)
			.solid(false).ret())
			.legacyId(6)
			.dataValue(5 | 8).build();
			
		registerBlock("leaves_big_oak", new Block().chainBlock()
			.texture("leaves_big_oak")
			.solid(false)
			.allowSelf(true)
			.colour(0xA7D389)
			.forceColour(true).ret())
			.legacyId(18)
			.dataValue(5)
			.build();
		// ============
		
		registerBlock("bedrock", new Block().chainBlock()
			.texture("bedrock").ret())
			.legacyId(7).build();
			
		// Liquids
		
		registerBlock("flowing_water", new BlockWater().chainBlock()
			.texture("water_flow")
			.solid(false)
			.transparent(true).ret())
			.legacyId(8).build();
		registerBlock("water", new BlockWater().chainBlock()
			.texture("water_still")
			.solid(false)
			.transparent(true).ret())
			.legacyId(9).build();
			
		registerBlock("flowing_lava", new Block().chainBlock()
			.texture("lava_flow")
			.solid(false).ret())
			.legacyId(10).build();
		registerBlock("lava", new Block().chainBlock()
			.texture("lava_still")
			.solid(false).ret())
			.legacyId(11).build();
			
		// Sand blocks
		{
			registerBlock("sand", new Block().chainBlock()
				.texture("sand").ret())
				.legacyId(12)
				.dataValue(0).build();
			registerBlock("sand_red", new Block().chainBlock()
				.texture("red_sand").ret())
				.legacyId(12)
				.dataValue(1).build();
		}
		
		registerBlock("gravel", new Block().chainBlock()
			.texture("gravel").ret())
			.legacyId(13).build();
			
		// Ores
		registerBlock("gold_ore", new Block().chainBlock()
			.texture("gold_ore").ret())
			.legacyId(14).build();
		registerBlock("iron_ore", new Block().chainBlock()
			.texture("iron_ore").ret())
			.legacyId(15).build();
		registerBlock("coal_ore", new Block().chainBlock()
			.texture("coal_ore").ret())
			.legacyId(16).build();
			
		// Logs
		var temp = [
			"oak" => 0,
			"spruce" => 1,
			"birch" => 2,
			"jungle" => 3
		];
		for (k in temp.keys()) {
			var v = temp[k];			
			registerBlock('log_${k}_up', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"top" => 'log_${k}_top',
					"bottom" => 'log_${k}_top',
					"front" => 'log_$k',
					"back" => 'log_$k',
					"left" => 'log_$k',
					"right" => 'log_$k'
				]).ret())
				.legacyId(17)
				.dataValue(v)
				.build();
			registerBlock('log_${k}_east', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"top" => 'log_$k',
					"bottom" => 'log_$k',
					"front" => 'log_$k',
					"back" => 'log_$k',
					"left" => 'log_${k}_top',
					"right" => 'log_${k}_top'
				]).ret())
				.legacyId(17)
				.dataValue(4 + v)
				.build();
			registerBlock('log_${k}_north', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"top" => 'log_$k',
					"bottom" => 'log_$k',
					"front" => 'log_${k}_top',
					"back" => 'log_${k}_top',
					"left" => 'log_$k',
					"right" => 'log_$k'
				]).ret())
				.legacyId(17)
				.dataValue(8 + v)
				.build();
			registerBlock('log_${k}_all', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"top" => 'log_$k',
					"bottom" => 'log_$k',
					"front" => 'log_$k',
					"back" => 'log_$k',
					"left" => 'log_$k',
					"right" => 'log_$k'
				]).ret())
				.legacyId(17)
				.dataValue(12 + v)
				.build();
		}
		
		registerBlock("sponge", new Block().chainBlock()
			.texture("sponge").ret())
			.legacyId(19).build();
		registerBlock("glass", new Block().chainBlock()
			.texture("glass").solid(false).ret())
			.legacyId(20).build();
		registerBlock("lapis_ore", new Block().chainBlock()
			.texture("lapis_ore").ret())
			.legacyId(21).build();
		registerBlock("lapis_block", new Block().chainBlock()
			.texture("lapis_block").ret())
			.legacyId(22).build();
			
		//Rotatable blocks
		{
			var ladder = new Model();
			ladder.faces.push(ModelFace.fromFace(Face.FRONT).moveZ(1).chainModelFace().texture("ladder").ret());
			var i = 0;
			var temp = [
				"north" => 2,
				"south" => 0,
				"west" => 1,
				"east" => 3
			];
			for (k in temp.keys()) {
				var v = temp[k];
				registerBlock('wall_sign_$k', new Block().chainBlock()
					.collidable(false)
					.solid(false)
					.texture("planks_oak")
					.model(BlockWallSign.model.clone().rotateY(v * 90)).ret())
					.legacyId(68)
					.dataValue(2 + i)
					.build();
				registerBlock('ladder_$k', new Block().chainBlock()
					.collidable(false)
					.solid(false)
					.model(ladder.clone().rotateY(v * 90)).ret())
					.legacyId(65)
					.dataValue(2 + i).build();
				registerBlock('dispenser_$k', new BlockSidedTextures().chainBlockSidedTextures()
					.textures([
						"top" => "furnace_top",
						"bottom" => "furnace_top",
						"left" => (v == 3 ? "dispenser_front_horizontal" : "furnace_side"),
						"right" => (v == 1 ? "dispenser_front_horizontal" : "furnace_side"),
						"front" => (v == 0 ? "dispenser_front_horizontal" : "furnace_side"),
						"back" => (v == 2 ? "dispenser_front_horizontal" : "furnace_side")
					]).ret())
					.legacyId(23)
					.dataValue(2 + i)
					.build();
				registerBlock('dropper_$k', new BlockSidedTextures().chainBlockSidedTextures()
					.textures([
						"top" => "furnace_top",
						"bottom" => "furnace_top",
						"left" => (v == 3 ? "dropper_front_horizontal" : "furnace_side"),
						"right" => (v == 1 ? "dropper_front_horizontal" : "furnace_side"),
						"front" => (v == 0 ? "dropper_front_horizontal" : "furnace_side"),
						"back" => (v == 2 ? "dropper_front_horizontal" : "furnace_side")
					]).ret())
					.legacyId(158)
					.dataValue(2 + i)
					.build();
				registerBlock('furnace_$k', new BlockSidedTextures().chainBlockSidedTextures()
					.textures([
						"top" => "furnace_top",
						"bottom" => "furnace_top",
						"left" => (v == 3 ? "furnace_front_off" : "furnace_side"),
						"right" => (v == 1 ? "furnace_front_off" : "furnace_side"),
						"front" => (v == 0 ? "furnace_front_off" : "furnace_side"),
						"back" => (v == 2 ? "furnace_front_off" : "furnace_side")
					]).ret())
					.legacyId(61)
					.dataValue(2 + i)
					.build();
				registerBlock('furnace_lit_$k', new BlockSidedTextures().chainBlockSidedTextures()
					.textures([
						"top" => "furnace_top",
						"bottom" => "furnace_top",
						"left" => (v == 3 ? "furnace_front_on" : "furnace_side"),
						"right" => (v == 1 ? "furnace_front_on" : "furnace_side"),
						"front" => (v == 0 ? "furnace_front_on" : "furnace_side"),
						"back" => (v == 2 ? "furnace_front_on" : "furnace_side")
					]).ret())
					.legacyId(62)
					.dataValue(2 + i)
					.build();
					
				registerBlock('chest_$k', new Block().chainBlock()
					.solid(false)
					.model(BlockChest.model.clone().rotateY(v * 90)).ret())
					.legacyId(54)
					.dataValue(2 + i)
					.build();
				registerBlock('hopper_$k', new Block().chainBlock()
					.solid(false)
					.model(BlockHopper.model.clone().join(BlockHopper.spout, 6, 4, 12).rotateY(v * 90)).ret())
					.legacyId(154)
					.dataValue(2 + i)
					.build();
				i++;
			}
		}
		
		// Up/Down blocks
		var temp = [
			"up" => 1,
			"down" => 0
		];
		for (k in temp.keys()) {
			var v = temp[k];
			registerBlock('dispenser_$k', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"top" => (v == 1 ? "dispenser_front_vertical" : "furnace_top"),
					"bottom" => (v == 0 ? "dispenser_front_vertical" : "furnace_top"),
					"left" => "furnace_top",
					"right" => "furnace_top",
					"front" => "furnace_top",
					"back" => "furnace_top"
				]).ret())
				.legacyId(23)
				.dataValue(v)
				.build();
			registerBlock('dropper_$k', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					"top" => (v == 1 ? "dropper_front_vertical" : "furnace_top"),
					"bottom" => (v == 0 ? "dropper_front_vertical" : "furnace_top"),
					"left" => "furnace_top",
					"right" => "furnace_top",
					"front" => "furnace_top",
					"back" => "furnace_top"
				]).ret())
				.legacyId(158)
				.dataValue(v)
				.build();
				
			registerBlock('hopper_$k', new Block().chainBlock()
				.solid(false)
				.model(BlockHopper.model.clone().join(BlockHopper.spout, 6, 0, 6)).ret())
				.legacyId(154)
				.dataValue(v)
				.build();
		}		
		
		// Sandstone
		var temp = [
			'normal' => 0,
			'carved' => 1,
			'smooth' => 2
		];
		for (k in temp.keys()) {
			var v = temp[k];
			registerBlock('sandstone_$k', new BlockSidedTextures().chainBlockSidedTextures()
				.textures([
					'top' => 'sandstone_top',
					'bottom' => 'sandstone_bottom',
					'left' => 'sandstone_$k',
					'right' => 'sandstone_$k',
					'front' => 'sandstone_$k',
					'back' => 'sandstone_$k'
			]).ret())
				.legacyId(24)
				.dataValue(v)
				.build();
		}

		registerBlock('noteblock', new Block().chainBlock().texture('noteblock').ret())
			.legacyId(25)
			.build();

		//TODO: (#26) Bed
		//TODO: (#27) Golden rail
		//TODO: (#28) Detector rail
		//TODO: (#29) Sticky piston

		registerBlock('web', new BlockCross().chainBlock().texture('web')
			.solid(false)
			.collidable(false).ret())
			.legacyId(30)
			.build();

		var temp = [
			'tallgrass' => 1,
			'fern' => 2,
			'deadbush' => 3
		];
		for (k in temp.keys()) {
			var v = temp[k];
			registerBlock('tallgrass_$k', new BlockCross().chainBlock().texture(k)
				.solid(false)
				.collidable(false)
				.forceColour(true)
				.colour(0xA7D389).ret())
				.legacyId(31)
				.dataValue(v)
				.build();
		}
		registerBlock('tallgrass_shrub', new BlockCross().chainBlock().texture('deadbush')
			.solid(false)
			.collidable(false).ret())
			.legacyId(31)
			.dataValue(0)
			.build();

		registerBlock('deadbush', new BlockCross().chainBlock().texture('deadbush')
			.solid(false)
			.collidable(false).ret())
			.legacyId(32)
			.dataValue(0)
			.build();

		//TODO: (#33) Piston
		//TODO: (#34) Piston head

		// Wool
		var temp = [
			'white' => 0,
			'orange' => 1,
			'magenta' => 2,
			'light_blue' => 3,
			'yellow' => 4,
			'lime' => 5,
			'pink' => 6,
			'gray' => 7,
			'silver' => 8,
			'cyan' => 9,
			'purple' => 10,
			'blue' => 11,
			'brown' => 12,
			'green' => 13,
			'red' => 14,
			'black' => 15
		];
		for (k in temp.keys()) {
			var v = temp[k];
			registerBlock('wool_$k', new Block().chainBlock().texture('wool_colored_$k').ret())
				.legacyId(35)
				.dataValue(v)
				.build();
			registerBlock('glass_$k', new Block().chainBlock()
				.texture('glass_$k')
				.solid(false)
				.transparent(true).ret())
				.legacyId(95)
				.dataValue(v)
				.build();
		}

		//TODO: (#36) Piston extension

		registerBlock('yellow_flower', new BlockCross().chainBlock().texture('dandelion')
			.solid(false)
			.collidable(false).ret())
			.legacyId(37)
			.build();

		var temp = [
			'rose' => 0,
			'blue_orchid' => 1,
			'allium' => 2,
			'houstonia' => 3,
			'tulip_red' => 4,
			'tulip_orange' => 5,
			'tulip_white' => 6,
			'tulip_pink' => 7,
			'oxeye_daisy' => 8
		];
		for (k in temp.keys()) {
			var v = temp[k];
			registerBlock('red_flower_$k', new BlockCross().chainBlock().texture('flower_$k')
				.solid(false)
				.collidable(false).ret())
				.legacyId(38)
				.dataValue(v)
				.build();
		}

		registerBlock('brown_mushroom', new BlockCross().chainBlock().texture('mushroom_brown')
			.solid(false)
			.collidable(false).ret())
			.legacyId(39)
			.build();
		registerBlock('red_mushroom', new BlockCross().chainBlock().texture('mushroom_red')
			.solid(false)
			.collidable(false).ret())
			.legacyId(40)
			.build();
		registerBlock('gold_block', new Block().chainBlock().texture('gold_block').ret())
			.legacyId(41)
			.build();
		registerBlock('iron_block', new Block().chainBlock().texture('iron_block').ret())
			.legacyId(42)
			.build();

		//TODO: (#43) Double stone slab
		//TODO: (#44) Stone slab

		registerBlock('brick_block', new Block().chainBlock().texture('brick').ret())
			.legacyId(45)
			.build();
		registerBlock('tnt', new BlockSidedTextures().chainBlockSidedTextures()
			.textures([
				'top' => 'tnt_top',
				'bottom' => 'tnt_bottom',
				'left' => 'tnt_side',
				'right' => 'tnt_side',
				'front' => 'tnt_side',
				'back' => 'tnt_side',
			]).ret())
			.legacyId(46)
			.build();
		registerBlock('bookshelf', new BlockSidedTextures().chainBlockSidedTextures()
			.textures([
				'top' => 'planks_oak',
				'bottom' => 'planks_oak',
				'left' => 'bookshelf',
				'right' => 'bookshelf',
				'front' => 'bookshelf',
				'back' => 'bookshelf'
			]).ret())
			.legacyId(47)
			.build();
		registerBlock('mossy_cobblestone', new Block().chainBlock().texture('cobblestone_mossy').ret())
			.legacyId(48)
			.build();
		registerBlock('obsidian', new Block().chainBlock().texture('obsidian').ret())
			.legacyId(49)
			.build();

		//TODO: (#50) Torch
		//TODO: (#51) Fire

		registerBlock('mob_spawner', new Block().chainBlock().texture('mob_spawner')
			.solid(false)
			.allowSelf(true).ret())
			.legacyId(52)
			.build();

		//TODO: (#53) Stairs

		//TODO: (#55) Redstone wire

		registerBlock('diamond_ore', new Block().chainBlock().texture('diamond_ore').ret())
			.legacyId(56)
			.build();
		registerBlock('diamond_block', new Block().chainBlock().texture('diamond_block').ret())
			.legacyId(57)
			.build();
		registerBlock('crafting_table', new BlockSidedTextures().chainBlockSidedTextures()
			.textures([
				'top' => 'crafting_table_top',
				'bottom' => 'planks_oak',
				'left' => 'crafting_table_side',
				'right' => 'crafting_table_side',
				'front' => 'crafting_table_front',
				'back' => 'crafting_table_front',
			]).ret())
			.legacyId(58)
			.build();

		//TODO: (#59) Wheat
		//TODO: (#60) Farmland

		for (i in 0 ... 16) {
			registerBlock('standing_sign_$i', new Block().chainBlock()
				.solid(false)
				.collidable(false)
				.model(BlockFloorSign.model.clone().rotateY((360/16)*i)).ret())
				.legacyId(63)
				.dataValue(i)
				.build();
		}
		
		//TODO: (#64) Wooden door

		//TODO: (#66) Rail
		//TODO: (#67) Stone stairs

		//TODO: (#69) Lever
		//TODO: (#70) Stone pressure plate
		//TODO: (#71) Iron door
		//TODO: (#72) Wooden pressure plate

		registerBlock('redstone_ore', new Block().chainBlock().texture('redstone_ore').ret())
			.legacyId(73)
			.build();
		registerBlock('lit_redstone_ore', new Block().chainBlock().texture('redstone_ore').ret())
			.legacyId(74)
			.build();

		//TODO: (#75) Unlit redstone torch
		//TODO: (#76) Redstone torch
		//TODO: (#77) Stone button
		//TODO: (#78) Snow layer

		registerBlock('ice', new Block().chainBlock().texture('ice')
			.solid(false)
			.transparent(true).ret())
			.legacyId(79)
			.build();
		registerBlock('snow', new Block().chainBlock().texture('snow').ret())
			.legacyId(80)
			.build();

		//TODO: (#81) Cactus

		registerBlock('clay', new Block().chainBlock().texture('clay').ret())
			.legacyId(82)
			.build();
		registerBlock('reeds', new BlockCross().chainBlock().texture('reeds')
			.solid(false).ret())
			.legacyId(83)
			.build();
		registerBlock('jukebox', new BlockSidedTextures().chainBlockSidedTextures()
			.textures([
				'top' => 'jukebox_top',
				'bottom' => 'jukebox_side',
				'left' => 'jukebox_side',
				'right' => 'jukebox_side',
				'back' => 'jukebox_side',
				'front' => 'jukebox_side'
			]).ret())
			.legacyId(84)
			.build();

		//TODO: (#85) Fence
		//TODO: (#86) Pumpkin

		registerBlock('netherrack', new Block().chainBlock().texture('netherrack').ret())
			.legacyId(87)
			.build();
		registerBlock('soulsand', new Block().chainBlock().texture('soul_sand').ret())
			.legacyId(88)
			.build();
		registerBlock('glowstone', new Block().chainBlock().texture('glowstone').ret())
			.legacyId(89)
			.build();

		//TODO: (#90) Portal
		//TODO: (#91) Lit pumpkin
		//TODO: (#92) Cake
		//TODO: (#93) Unpowered repeater
		//TODO: (#94) Powered repeater
		//TODO: (#95) Stained glass
		//TODO: (#96) Trapdoor
		//TODO: (#97) Monster egg

		// Stone bricks
		{
			registerBlock('stonebrick', new Block().chainBlock().texture('stonebrick').ret())
				.legacyId(98)
				.dataValue(0)
				.build();
			registerBlock('stonebrick_mossy', new Block().chainBlock().texture('stonebrick_mossy').ret())
				.legacyId(98)
				.dataValue(1)
				.build();
			registerBlock('stonebrick_cracked', new Block().chainBlock().texture('stonebrick_cracked').ret())
				.legacyId(98)
				.dataValue(2)
				.build();
			registerBlock('stonebrick_carved', new Block().chainBlock().texture('stonebrick_carved').ret())
				.legacyId(98)
				.dataValue(3)
				.build();
		}

		//TODO: (#99) Brown mushroom block
		//TODO: (#100) Red mushroom block
		//TODO: (#101) Iron bars
		//TODO: (#102) Glass pane
		//TODO: (#103) Melon block
		//TODO: (#104) Pumpkin stem
		//TODO: (#105) Melon stem

		BlockVine.register();

		//TODO: (#107) Fence gate
		//TODO: (#108) Brick stairs
		//TODO: (#109) Stone brick stairs
		//TODO: (#110) Mycelium
		//TODO: (#111) Waterlily
		//TODO: (#112) Nether brick
		//TODO: (#113) Nether brick fence
		//TODO: (#114) Nether brick stairs
		//TODO: (#115) Nether wart
		//TODO: (#116) Enchanting table
		//TODO: (#117) Brewing stand
		//TODO: (#118) Cauldron
		//TODO: (#119) End portal
		//TODO: (#120) End portal frame
		//TODO: (#121) End stone
		//TODO: (#122) Dragon egg
		//TODO: (#123) Redstone lamp
		//TODO: (#124) Lit redstone lamp
		//TODO: (#125) Double wooden slab
		//TODO: (#126) Wooden slab
		//TODO: (#127) Cocoa
		//TODO: (#128) Sandstone stairs
		//TODO: (#129) Emerald ore
		//TODO: (#130) Ender chest
		//TODO: (#131) Tripwire hook
		//TODO: (#132) Tripwire
		//TODO: (#133) Emerald block
		//TODO: (#134) Spruce stairs
		//TODO: (#135) Birch stairs
		//TODO: (#136) Jungle stairs
		//TODO: (#137) Command block
		//TODO: (#138) Beacon
		//TODO: (#139) Cobblestone wall
		//TODO: (#140) Flower pot
		//TODO: (#141) Carrots
		//TODO: (#142) Potatoes
		//TODO: (#143) Wooden button
		//TODO: (#144) Skull
			
		for (deg in 0 ... 4) {
			for (dam in 0 ... 3) {
				registerBlock('anvil_${deg}_$dam', new Block().chainBlock()
					.solid(false)
					.model(Model.get("anvil").clone(function(t) {
						return t == "anvil_top_damaged_0" ? 'anvil_top_damaged_$dam' : t;
					}).rotateY(deg * 90))
					.ret())
					.legacyId(145)
					.dataValue(dam << 2 | deg)
					.build();				
			}
		}
		
		//TODO: (#146) Trapped chest
		//TODO: (#147) Light weighted pressure plate
		//TODO: (#148) Heavy weighted pressure plate
		//TODO: (#149) Unpowered comparator
		//TODO: (#150) Powered comparator
		//TODO: (#151) Daylight detector
		//TODO: (#152) Redstone block
		//TODO: (#153) Quartz ore

		//TODO: (#155) Quartz block
		//TODO: (#156) Quartz stairs
		//TODO: (#157) Activator rail

		//TODO: (#159) Stained hardened clay
		//TODO: (#160) Stained glass pane
		//TODO: (#161) Leaves2
		//TODO: (#162) Log2
		//TODO: (#163) Acacia stairs
		//TODO: (#164) Dark oak stairs

		// Range (#165) -> (#169) unused currently

		//TODO: (#170) Hay block
		//TODO: (#171) Carpet
		//TODO: (#172) Hardened clay
		//TODO: (#173) Coal block
		//TODO: (#174) Packed ice
		//TODO: (#175) Double plant

		// Custom blocks
        registerBlock("missing_block", new Block().chainBlock()
            .texture("missing_texture")
            .ret(), "webglmap")
            .build();
        registerBlock("null", new Block().chainBlock()
            .renderable(false)
            .shade(false)
            .ret(), "webglmap").build();
    }
}

class BlockRegistrationEntry {
    public var plugin : String;
    public var name : String;
    public var block : Block;

    // Legacy Support
    private var _legacyId : Int = -1;
    private var allDataValues : Bool = true;
    private var _dataValue : Int;

    public function new(plugin : String, name : String, block : Block) {
        this.plugin = plugin;
        this.name = name;
        this.block = block;
    }

    public function toString() : String {
        return '$plugin:$name';
    }

    // Builder things

    private var hasBuilt : Bool = false;

    public function build() {
        hasBuilt = true;

        // Handle legacy stuff
        // TODO: Remove once minecraft drops it
        if (_legacyId == -1) return; // Doesn't exist in the old system
        if (allDataValues) {
            if (plugin != "minecraft") BlockRegistry.logger.warn('$this is using legacy block ids ($_legacyId)');
            BlockRegistry.legacyMap[_legacyId] = new SingleBlockEntry(this);
        } else {
            if (plugin != "minecraft") BlockRegistry.logger.warn('$this is using legacy block ids ($_legacyId:$_dataValue)');
            if (BlockRegistry.legacyMap[_legacyId] == null) {
                BlockRegistry.legacyMap[_legacyId] = new MultiBlockEntry();
            }
            var map : MultiBlockEntry = cast BlockRegistry.legacyMap[_legacyId];
            map.byData[_dataValue] = this;
        }
    }

    private function checkBuild() {
        if (hasBuilt) throw "Cannot changeproperties of a BlockRegistrationEntry after build";
    }

    public function legacyId(id : Int) : BlockRegistrationEntry {
        checkBuild();
        _legacyId = id;
        return this;
    }

    public function dataValue(val : Int) : BlockRegistrationEntry {
        checkBuild();
        allDataValues = false;
        _dataValue = val;
        return this;
    }
}

/**
 * An entry for a block that can convert Minecraft data value
 * into a registered block
 */
private interface BlockEntry {

    /**
     * Returns a registered block based on the data value
     */
    public function getBlock(data : Int) : BlockRegistrationEntry;
}

/**
 * A BlockEntry that always returns the same block
 */
private class SingleBlockEntry implements BlockEntry {

    private var block : BlockRegistrationEntry;

    public function new(block : BlockRegistrationEntry) {
        this.block = block;
    }

    public function getBlock(data : Int) : BlockRegistrationEntry {
        return block;
    }
}

/**
 * A BlockEntry that will return 1 of 16 blocks based on
 * passed data value
 */
private class MultiBlockEntry implements BlockEntry {

    public var byData : Array<BlockRegistrationEntry>;

    public function new() {
        byData = new Array();
    }

    public function getBlock(data : Int) : BlockRegistrationEntry {
        return byData[data];
    }
}