#!/usr/bin/env ruby
# coding: utf-8

require 'fox16'
include Fox

class MainWindow < FXMainWindow
  GREEN = FXRGB(0,  255,  0)
  RED   = FXRGB(255,  0,  0)
  BLUE  = FXRGB(0,    0,255)
  WHITE = FXRGB(255,255,255)
  GRAY  = FXRGB(128,128,128)

  def initialize(app)
    super(app, "Animal Chess", :opts => DECOR_ALL, :width => 840, :height => 490)
    @piece_lion     = load_icon("lion.png") 
    @piece_giraffe  = load_icon("giraffe.png") 
    @piece_elephant = load_icon("elephant.png") 
    @piece_cock     = load_icon("cock.png") 
    @piece_chick    = load_icon("chick.png") 
    @piece_lion_inv     = load_icon("lion_inv.png") 
    @piece_giraffe_inv  = load_icon("giraffe_inv.png") 
    @piece_elephant_inv = load_icon("elephant_inv.png") 
    @piece_cock_inv     = load_icon("cock_inv.png") 
    @piece_chick_inv    = load_icon("chick_inv.png") 

    @pieces = [@piece_lion, @piece_giraffe, @piece_elephant, \
               @piece_cock, @piece_chick, @piece_lion_inv, @piece_giraffe_inv, \
               @piece_elephant_inv, @piece_cock_inv, @piece_chick_inv]
    @grabbed_piece = nil
    @grabbed_rs_piece = nil
    
    # main_frame
    main_frame = FXHorizontalFrame.new(self, :opts => LAYOUT_FILL_Y| \
                                       LAYOUT_SIDE_LEFT|LAYOUT_FIX_WIDTH,\
                                       :width => 280)
    @main_table = FXTable.new(main_frame, :opts => LAYOUT_FILL|TABLE_READONLY)
    @main_table.defColumnWidth = 90
    @main_table.defRowHeight = 120
    @main_table.setTableSize(4,3)
    ## hide table header row and col
    @main_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @main_table.rowHeaderWidth = 0
    @main_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @main_table.columnHeaderHeight = 0
    ## event
    @main_table.connect(SEL_COMMAND, method(:on_cell_click))

    # sub_frame
    sub_frame = FXVerticalFrame.new(self, :opts => LAYOUT_FIX_WIDTH| \
                                    LAYOUT_FIX_HEIGHT|LAYOUT_SIDE_RIGHT, \
                                    :x => 280, :y => 0, \
                                    :width => 555, :height => 480)
    sub_box = FXMatrix.new(sub_frame, 3, MATRIX_BY_ROWS|LAYOUT_FILL)
    # sub_frame_btm
    sub_frame_btm = FXHorizontalFrame.new(sub_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT|LAYOUT_SIDE_RIGHT| \
                                          LAYOUT_SIDE_BOTTOM, \
                                          :width => 555, :height => 130)
    @reserve1_table = FXTable.new(sub_frame_btm, \
                                  :opts => LAYOUT_FILL|TABLE_READONLY)
    @reserve1_table.defColumnWidth = 90
    @reserve1_table.defRowHeight = 120
    @reserve1_table.setTableSize(1,6)
    ## hide table header row and col
    @reserve1_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @reserve1_table.rowHeaderWidth = 0
    @reserve1_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @reserve1_table.columnHeaderHeight = 0

    # sub_fame_mid
    sub_frame_mid = FXHorizontalFrame.new(sub_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT, \
                                          :width => 555, :height => 200)
    
    @start_btn = FXButton.new(sub_frame_mid, "Game Start", :opts => FRAME_RAISED| \
                              LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, \
                              :width => 100, :height => 120)
    @start_btn.connect(SEL_COMMAND, method(:on_start_btn_click))
    
    group = FXGroupBox.new(sub_frame_mid, "Game Mode", GROUPBOX_TITLE_CENTER| \
                           LAYOUT_CENTER_Y|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT,\
                           :width => 120, :height => 120)
    @group_dt = FXDataTarget.new(3)
    @group_dt.connect(SEL_COMMAND) do
    end
    FXRadioButton.new(group, "Man vs Man", @group_dt, FXDataTarget::ID_OPTION)
    FXRadioButton.new(group, "Man vs Comp", @group_dt, FXDataTarget::ID_OPTION+1)
    FXRadioButton.new(group, "Comp vs Man", @group_dt, FXDataTarget::ID_OPTION+2)
    FXRadioButton.new(group, "Comp vs Comp", @group_dt, FXDataTarget::ID_OPTION+3)
    

    # sub_frame_top
    sub_frame_top = FXHorizontalFrame.new(sub_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT|LAYOUT_SIDE_RIGHT| \
                                          LAYOUT_SIDE_TOP, \
                                          :width => 555, :height => 130)
    @reserve2_table = FXTable.new(sub_frame_top, \
                                  :opts => LAYOUT_FILL|TABLE_READONLY)
    @reserve2_table.defColumnWidth = 90
    @reserve2_table.defRowHeight = 120
    @reserve2_table.setTableSize(1,6)
    ## hide table header row and col
    @reserve2_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @reserve2_table.rowHeaderWidth = 0
    @reserve2_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @reserve2_table.columnHeaderHeight = 0

    # init pieces place
    putPiece(0, 0, @piece_giraffe_inv)
    putPiece(0, 1, @piece_lion_inv)
    putPiece(0, 2, @piece_elephant_inv)
    putPiece(1, 1, @piece_chick_inv)
    putPiece(2, 1, @piece_chick)
    putPiece(3, 0, @piece_elephant)
    putPiece(3, 1, @piece_lion)
    putPiece(3, 2, @piece_giraffe)

  end

  def putPiece(row, col, piece)
    @main_table.setItemIcon(row, col, piece)
  end

  def on_start_btn_click(sender, sel, event)
    p "game start."
  end

  def on_cell_click(sender, sel, pos)
    icon = @main_table.getItemIcon(pos.row, pos.col)
    if icon == nil
      p "icon doesn't exist."
      @pieces.each do |p|
        if @grabbed_piece == p
          putPiece(pos.row, pos.col, p)
        end
      end
   else
      p "icon exists."
      # cannot put
      # TODO
      #

      # get opposite side piece
      if @grabbed_piece != nil
        p "aleady grabbed."
        @main_table.removeItem(pos.row, pos.col)
        p "removed item"
        @pieces.each do |p|
          if @grabbed_piece == p
            putPiece(pos.row, pos.col, p)
          end
        end
        # TODO
        # put reserver area
        @grabbed_piece = nil
        return
      end
      
      # put piece to empty pos
      @pieces.each do |p|
        if icon == p
          @grabbed_piece = icon
        end
      end
     
      @main_table.removeItem(pos.row, pos.col)
    end
  end


  def load_icon(fname)
    begin
      fname = File.join("asset",fname)
      icon = nil
      File.open(fname, "rb") do |f|
        icon = FXPNGIcon.new(getApp(), f.read)
      end
      icon
    rescue
      raise RuntimeError, "Couldn't load icon: #{fname}"
    end
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  app = FXApp.new("AnimalChess", "Example")
  MainWindow.new(app)
  app.create
  app.run
end

