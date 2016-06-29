#!/usr/bin/env ruby
# coding: utf-8
#
#  animal_chess.rb
#
#  Board Index
#
#    0 1 2 Col
#  0
#  1
#  2
#  3
# Row
#

require 'fox16'
include Fox

class MainWindow < FXMainWindow

  TITLE = "Animal Chess"
  VERSION = " 0.9.0"
  VEC_LION         = [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
  VEC_LION_INV     = VEC_LION
  VEC_GIRAFFE      = [[-1,0],[0,-1],[0,1],[1,0]]
  VEC_GIRAFFE_INV  = VEC_GIRAFFE
  VEC_ELEPHANT     = [[-1,-1],[-1,1],[1,-1],[1,1]]
  VEC_ELEPHANT_INV = VEC_ELEPHANT
  VEC_COCK         = [[-1,0],[-1,-1],[0,-1],[0,1],[1,0],[1,-1]]
  VEC_COCK_INV     = [[-1,0],[-1,1],[0,-1],[0,1],[1,0],[1,1]]
  VEC_CHICK        = [[-1,0]]
  VEC_CHICK_INV    = [[1,0]]

  def initialize(app)
    super(app, TITLE+VERSION, :opts => DECOR_ALL, :width => 890, :height => 500)
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

    @pieces_upright = [@piece_lion, @piece_giraffe, @piece_elephant, \
                      @piece_cock, @piece_chick]
    @pieces_inverse = [@piece_lion_inv, @piece_giraffe_inv, \
                      @piece_elephant_inv, @piece_cock_inv, @piece_chick_inv]
    @pieces = [@pieces_upright,  @pieces_inverse]
    @grabbed_piece = nil
    @grabbed_from = [nil, nil, nil] # [table, row, col]
    @turn = {"first"=>0, "second"=>1}
    @now_turn = @turn['first']
   
    base_frame = FXHorizontalFrame.new(self, :opts => LAYOUT_FILL) 
    # main_frame
    main_frame = FXHorizontalFrame.new(base_frame, :opts => LAYOUT_FILL_Y| \
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
    @main_table.connect(SEL_COMMAND, method(:on_main_click))

    # mid_frame
    mid_frame = FXVerticalFrame.new(base_frame, :opts => LAYOUT_FILL_Y| \
                                    LAYOUT_FIX_WIDTH| LAYOUT_FIX_HEIGHT, \
                                    :width => 30, :height => 480)
    mid_box = FXMatrix.new(mid_frame, 2, MATRIX_BY_ROWS|LAYOUT_FILL)
    mid_frame_top = FXHorizontalFrame.new(mid_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT, :width => 25, \
                                          :height => 410)
    mid_frame_btm = FXHorizontalFrame.new(mid_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT, :width => 25, \
                                          :height => 50)
    @turn_light2 = FXText.new(mid_frame_top, :opts => LAYOUT_FILL_X| \
                              TEXT_READONLY)
    @turn_light1 = FXText.new(mid_frame_btm, :opts => LAYOUT_FILL_X| \
                              TEXT_READONLY)

    # sub_frame
    sub_frame = FXVerticalFrame.new(base_frame, :opts => LAYOUT_FIX_WIDTH| \
                                    LAYOUT_FIX_HEIGHT|LAYOUT_SIDE_RIGHT, \
                                    :x => 300, :y => 0, \
                                    :width => 555, :height => 480)
    sub_box = FXMatrix.new(sub_frame, 3, MATRIX_BY_ROWS|LAYOUT_FILL)

    # sub_frame_top
    sub_frame_top = FXHorizontalFrame.new(sub_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT|LAYOUT_SIDE_RIGHT, \
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
    @reserve2_table.connect(SEL_COMMAND, method(:on_reserve2_click))
    
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
    FXRadioButton.new(group, "Man vs Man", @group_dt, FXDataTarget::ID_OPTION)
    FXRadioButton.new(group, "Man vs Comp", @group_dt, FXDataTarget::ID_OPTION+1)
    FXRadioButton.new(group, "Comp vs Man", @group_dt, FXDataTarget::ID_OPTION+2)
    FXRadioButton.new(group, "Comp vs Comp", @group_dt, FXDataTarget::ID_OPTION+3)
    @group_dt.value = 0
    @log_text = FXText.new(sub_frame_mid, :opts => LAYOUT_FIX_WIDTH| \
                           LAYOUT_FIX_HEIGHT, :width => 300, :height => 200)
 
    # sub_frame_btm
    sub_frame_btm = FXHorizontalFrame.new(sub_box, :opts => LAYOUT_FIX_WIDTH| \
                                          LAYOUT_FIX_HEIGHT, \
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
    @reserve1_table.connect(SEL_COMMAND, method(:on_reserve1_click))

    @tables = {"main"=>@main_table, "reserve1"=>@reserve1_table, \
               "reserve2"=>@reserve2_table}

    # out_table is needed for showing all icon to use.
    # refer to "http://fox-toolkit.org/faq.html#ILLEGALICON"
    out_frame = FXHorizontalFrame.new(base_frame, :opts => LAYOUT_FIX_WIDTH| \
                                      LAYOUT_FIX_HEIGHT, :x => 870, :width=>5,\
                                      :height => 480)
    @out_table = FXTable.new(out_frame, :opts => LAYOUT_FILL|TABLE_READONLY)
    @out_table.defColumnWidth = 90
    @out_table.defRowHeight = 120
    @out_table.setTableSize(4,3)
    @out_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @out_table.rowHeaderWidth = 0
    @out_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @out_table.columnHeaderHeight = 0
    # show all icon to use
    @out_table.setItemIcon(0, 0, @piece_lion)
    @out_table.setItemIcon(0, 1, @piece_lion_inv)
    @out_table.setItemIcon(0, 2, @piece_giraffe)
    @out_table.setItemIcon(1, 0, @piece_giraffe_inv)
    @out_table.setItemIcon(1, 1, @piece_elephant)
    @out_table.setItemIcon(1, 2, @piece_elephant_inv)
    @out_table.setItemIcon(2, 0, @piece_cock)
    @out_table.setItemIcon(2, 1, @piece_cock_inv)
    @out_table.setItemIcon(2, 2, @piece_chick)
    @out_table.setItemIcon(3, 0, @piece_chick_inv)
    
    # init all state
    init_state()
  end

  def init_state()
    4.times do |i|
      3.times do |j|
        @main_table.removeItem(i, j)
      end
    end
    6.times do |i|
      @reserve1_table.removeItem(0, i)
      @reserve2_table.removeItem(0, i)
    end
    @main_table.setItemIcon(0, 0, @piece_giraffe_inv)
    @main_table.setItemIcon(0, 1, @piece_lion_inv)
    @main_table.setItemIcon(0, 2, @piece_elephant_inv)
    @main_table.setItemIcon(1, 1, @piece_chick_inv)
    @main_table.setItemIcon(2, 1, @piece_chick)
    @main_table.setItemIcon(3, 0, @piece_elephant)
    @main_table.setItemIcon(3, 1, @piece_lion)
    @main_table.setItemIcon(3, 2, @piece_giraffe)
    @log_text.removeText(0, @log_text.length)
    @grabbed_piece = nil 
    @grabbed_from = [nil, nil, nil]
    @now_turn = @turn['first']
    @turn_light1.backColor = FXRGB(255,0,0)
    @turn_light2.backColor = FXRGB(255,255,255)
    @game_is_end = false
  end

  def is_grabbable(table, row, col)
    p "is_grabbable called."
    ret = false
    # piece doesn't exist or you have already grabbed.
    if table.getItemIcon(row, col) == nil || @grabbed_piece != nil
      return false
    end
    
    if @now_turn == @turn['first']
      if (table == @tables['reserve1']) || \
         (table == @tables['main'] && is_upright(table.getItemIcon(row, col)))
        ret = true
      end
    else
      if (table == @tables['reserve2']) || \
         (table == @tables['main'] && not(is_upright(table.getItemIcon(row, col))))
        ret = true
      end
    end
    p "is_grabbable ret = " + ret.to_s
    ret
  end

  def is_upright(piece)
    p "is_upright called."
    p piece.to_s
    if piece == nil
      ret = nil
    else
      ret = false
      @pieces_upright.each do |p|
        if p == piece
          ret = true
        end
      end
    end
    p "is_upright ret = " + ret.to_s
    ret
  end

  def grab_piece(from)
    p "grab piece"
    ret = false
    if is_grabbable(from[0], from[1], from[2])
      @grabbed_piece = from[0].getItemIcon(from[1], from[2])
      @grabbed_from = from
      from[0].removeItem(from[1], from[2])
      ret = true
    end
    ret
  end

  def is_puttable(row, col) # only main_table is puttable
    p "is_puttable called."
    ret = false
    if @grabbed_from[0] == @tables['main']
      pos_list, got_list = scan_movable(@grabbed_from[1], @grabbed_from[2], \
                                        @grabbed_piece)
      p "pos_list = " + pos_list.to_s 
      p "got_list = " + got_list.to_s 
      # If pos_list is empty, grabbed piece cannot move.
      if pos_list.empty?
        @main_table.setItemIcon(@grabbed_from[1], @grabbed_from[2], @grabbed_piece)
        @grabbed_piece = nil
        @grabbed_from = [nil, nil, nil]
        ret = false
      else
        # If (row,col) is included in pos_list, hit is not nil
        hit = pos_list.delete([row,col])
        if hit != nil
          ret = true
        end
      end
    elsif @grabbed_from[0] == @tables['reserve1'] || \
          @grabbed_from[0] == @tables['reserve2']
      if @main_table.getItemIcon(row, col) == nil
        ret = true
      end
    else
      # didn't grab any piece
      ret = false
    end
    ret
  end

  def put_piece(row, col)
    ret = false
    if is_puttable(row, col)
      p 'is_puttable = true'
      got_piece = @main_table.getItemIcon(row, col)
      # get opposite piece into reserve table
      if got_piece != nil
        # catch the lion
        if got_piece == @piece_lion || got_piece == @piece_lion_inv
          game_end
        else
          go_reserve(got_piece)
        end
      end
      p 'put piece.'
      # transform chick to cock
      if @grabbed_from[0] == @tables['main'] && \
         @grabbed_piece == @piece_chick && row == 0
        @grabbed_piece = @piece_cock
      elsif @grabbed_from[0] == @tables['main'] && \
            @grabbed_piece == @piece_chick_inv && row == 3
        @grabbed_piece = @piece_cock_inv
      end

      @main_table.setItemIcon(row, col, @grabbed_piece)
      @grabbed_piece = nil
      @grabbed_from = [nil, nil, nil]
      ret = true
    end
    ret
  end

  def scan_movable(now_row, now_col, piece)
    pos_list = []
    got_piece_list = []
    case piece
    when @piece_lion
      vec = VEC_LION
      is_up = true
    when @piece_giraffe
      vec = VEC_GIRAFFE
      is_up = true
    when @piece_elephant
      vec = VEC_ELEPHANT
      is_up = true
    when @piece_cock
      vec = VEC_COCK
      is_up = true
    when @piece_chick
      vec = VEC_CHICK
      is_up = true
    when @piece_lion_inv
      vec = VEC_LION_INV
      is_up = false
    when @piece_giraffe_inv
      vec = VEC_GIRAFFE_INV
      is_up = false
    when @piece_elephant_inv
      vec = VEC_ELEPHANT_INV
      is_up = false
    when @piece_cock_inv
      vec = VEC_COCK_INV
      is_up = false
    when @piece_chick_inv
      vec = VEC_CHICK_INV
      is_up = false
    else
      p "Error! illegal path."
      return ret
    end

    vec.each do |v|  
      if (v[0] + now_row) >= 0 && (v[0] + now_row) < 4 && \
         (v[1] + now_col) >= 0 && (v[1] + now_col) < 3
        pos_list.push([v[0]+now_row, v[1]+now_col])
      end
    end
    
    del_pos_list = []
    pos_list.each_with_index do |pos, index|
      p "pos, index = " + pos.to_s + ", " + index.to_s
      cur_icon = @main_table.getItemIcon(pos[0], pos[1])
      got_piece_list.push(cur_icon)
      if cur_icon == nil
        next
      end
      # cannot put on the piece of my side.
      if is_up == is_upright(cur_icon)
        p "pos_list = " + pos_list.to_s
        p "got_list = " + got_piece_list.to_s
        del_pos_list.push(pos)
        got_piece_list.delete_at(got_piece_list.length - 1)
      end
    end

    del_pos_list.each do |pos|
      pos_list.delete(pos)
    end
    
    return pos_list, got_piece_list
  end

  # full_scan_movable
  # Scan the puttable postions of all pieces specified by "is_up" with got pieces
  #
  # is_up : true  => all uprihgt piece
  #         false => all inverse pieces
  #
  # ret = move_piece_list, pos_list, got_piece_list,
  #   move_pieces : move piece list [[from main_table],[from reserve_table]]
  #   pos_list    : move pos list [[from main_table],[from reserve_table]]
  #   got_pieces  : got piece list [[from main_table],[from reserve_table]]
  def full_scan_movable(is_up)
    main_move_pieces = []
    main_pos_list    = []
    main_got_pieces  = []
    reserve_move_pieces = []
    reserve_pos_list    = []
    reserve_got_pieces  = []
    empty_pos_list = []  # These positions doesn't have any piece.
    # scan main_table
    4.times do |row|
      3.times do |col|
        icon = @main_table.getItemIcon(row, col)
        if icon == nil
          empty_pos_list.push([row,col])
          next
        end

        if is_up == is_upright(icon)
          main_move_pieces.push(icon)
          temp_pos_list, temp_got_pieces = scan_movable(row, col, icon)
          main_pos_list += temp_pos_list
          main_got_pieces += temp_got_pieces
        end
      end
    end

    # scan reserve_table
    if is_up
      reserve_table = @tables['reserve1']
    else
      reserve_table = @tables['reserve2']
    end
    
    6.times do |i|
      icon = reserve_table.getItemIcon(0, i)
      reserve_move_pieces.push(icon)
      reserve_pos_list += empty_pos_list
      reserve_got_pieces.push(nil)
    end
    
    return [main_move_pieces, reserve_move_pieces], \
           [main_pos_list, reserve_pos_list], \
           [main_got_pieces, reserve_got_pieces]
  end

  def go_reserve(piece)
    if @now_turn == @turn['first']
      p "go reserve1"
      table = @tables['reserve1']
      to_inv = false
    else
      p "go reserve2"
      table = @tables['reserve2']
      to_inv = true
    end
    # each reserve area has 6 cells.
    6.times do |i|
      p "i=" + i.to_s
      icon = table.getItemIcon(0,i)
      if icon == nil
        inv_piece = invert_piece(piece, to_inv)
        p inv_piece.to_s 
        table.setItemIcon(0, i, inv_piece)
        break
      end
    end
  end
  
  def invert_piece(piece, to_inv)
    p "invert piece"
    ret = nil
    if to_inv
      pieces = @pieces_upright  # search pieces
      index = 1                 # inverted pieces index
    else
      pieces = @pieces_inverse  # search pieces
      index = 0                 # inverted pieces index
    end
    # kinds of pieces are 5.
    5.times do |i|
      if pieces[i] == piece
        ret = @pieces[index][i]
        break
      end
    end
    ret
  end

  def game_end
    @log_text.appendText("Game is end.\n")
    @game_is_end = true
  end

  def next_turn
    p "next trun"
    @now_turn = (@now_turn + 1) % 2

    if @turn_light1.backColor == FXRGB(255,0,0)
      @turn_light1.backColor = FXRGB(255,255,255)
      @turn_light2.backColor = FXRGB(255,0,0)
    else
      @turn_light1.backColor = FXRGB(255,0,0)
      @turn_light2.backColor = FXRGB(255,255,255)
    end

  end

  # judge wheter "Try" succeeded or not before next turn start.
  def judge_try
    on_try = false
    try_success = false
    try_pos = []

    # scan lion opposite side
    if @now_turn == @turn['first']
      piece_lion = @piece_lion
      row = 0
      is_upright = false
    else
      piece_lion = @piece_lion_inv
      row = 3
      is_upright = true
    end
 
    3.times do |i|
      icon = @main_table.getItemIcon(row, i)
      if icon == piece_lion
        on_try = true
        try_pos = [row, i]
      end
    end
   
    if on_try
      move_pieces, pos_list, got_pieces = full_scan_movable(is_upright)
      p "pos_list[0] = " + pos_list[0].to_s
      p "try_pos = " + try_pos.to_s
      hit = pos_list[0].delete(try_pos)
      if hit == nil
        try_success = true
      end
    end

     return on_try, try_success
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

  def doComputer(pos)
    if @game_is_end
      return
    end

  end

  def on_start_btn_click(sender, sel, event)
    p "game start."
    init_state
  end

  def on_main_click(sender, sel, pos)
    if @game_is_end
      return
    end
    p 'grabbed piece = ' + @grabbed_piece.to_s
    p 'click pos = ' + [pos.row, pos.col].to_s
    if grab_piece([sender, pos.row, pos.col])
      p "grab piece."
    elsif put_piece(pos.row, pos.col)
      p "put piece."
      if @game_is_end
        return
      end
      on_try, try_success = judge_try
      if on_try && try_success
        @game_is_end = true
        @log_text.appendText("'Try' succeeded.\n")
        @log_text.appendText("Game is end.\n")
      elsif on_try && !try_success
        @game_is_end = true
        @log_text.appendText("'Try' failed.\n")
        @log_text.appendText("Game is end.\n")
      end
      next_turn
    else
      p "nothing to do."
    end
  end

  def on_reserve1_click(sender, sel, pos)
    p "reserve1 click"
    grab_piece([sender, pos.row, pos.col])
  end

  def on_reserve2_click(sender, sel, pos)
    p "reserve2 click"
    grab_piece([sender, pos.row, pos.col])
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

