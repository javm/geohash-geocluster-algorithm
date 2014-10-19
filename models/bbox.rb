  class Bbox
    attr_accessor :p1, :p2
    def initialize(p1, p2)
      if p1[0] < p2[0] and p1[1] < p2[1]
        @p1 = p1
        @p2 = p2
      else
        raise ArgumentError, "Rectangle should have points in order p1 leftmost bottom p2 rigthmost upper"
      end
    end

    def p1x
      p1[0]
    end

    def p1y
      p1[1]
    end

    def p2x
      p2[0]
    end

    def p2y
      p2[1]
    end

    def middle_point
      m = (p1x + p2x) / 2
      n = (p1y + p2y) / 2
      return [m,n]
    end
  end
