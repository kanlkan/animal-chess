#!/usr/bin/env ruby
# coding: utf-8

require 'fox16'
include Fox

class MainWindow < FXMainWindow
  GREEN = FXRGB(0,  255,  0)
  WHITE = FXRGB(255,255,255)
  GRAY  = FXRGB(128,128,128)

  def initialize(app)
    super(app, "Animal Chess", :opts => DECOR_ALL, :width => 480, :height => 490)
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

    main_frame = FXHorizontalFrame.new(self, :opts => LAYOUT_FILL_Y| \
                                        LAYOUT_FIX_WIDTH, :width => 280)
    @main_table = FXTable.new(main_frame, :opts => LAYOUT_FILL|TABLE_READONLY)
    @main_table.defColumnWidth = 90
    @main_table.defRowHeight = 120
    @main_table.setTableSize(4,3)
    # hide table header row and col
    @main_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @main_table.rowHeaderWidth = 0
    @main_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @main_table.columnHeaderHeight = 0
    # event
    @main_table.connect(SEL_COMMAND, method(:on_cell_click))
    # init place
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

  def left_click
    image = FXPNGImage.new(getApp(), nil)
    FXFileStream.open("asset/temp.png", FXStreamLoad) do |stream|
      image.loadPixels(stream)
    end
    image.create
    @view.image = image
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

