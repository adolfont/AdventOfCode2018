defmodule SlicerTest do
  use ExUnit.Case
  doctest Slicer

  test "parse a claim" do
    assert Slicer.parse("#13 @ 921,321: 10x27") == ["13", "921", "321", "10", "27"]
  end

  test "make a claim" do
    assert Slicer.make_claim("#13 @ 921,321: 10x27") == [
             id: 13,
             left: 921,
             top: 321,
             width: 10,
             height: 27
           ]
  end

  test "all claims are not nil" do
    assert Slicer.all_claims("input") != []
  end

  test "make interval from claim" do
    claim = Slicer.make_claim("#1 @ 1,3 4x4")
    assert Slicer.make_interval(claim) == [x1: 2, y1: 4, x2: 5, y2: 7]
  end

  test "find interval intersection between two claims that is 4,4,5,5" do
    claim_1 = Slicer.make_claim("#1 @ 1,3 4x4")
    interval_1 = Slicer.make_interval(claim_1)
    assert interval_1 == [x1: 2, y1: 4, x2: 5, y2: 7]

    claim_2 = Slicer.make_claim("#2 @ 3,1 4x4")
    interval_2 = Slicer.make_interval(claim_2)
    assert interval_2 == [x1: 4, y1: 2, x2: 7, y2: 5]
    assert Slicer.interval_intersection(interval_1, interval_2) == [x1: 4, y1: 4, x2: 5, y2: 5]
  end

  test "find interval intersection between two claims that is nil" do
    claim_1 = Slicer.make_claim("#1 @ 1,3 4x4")
    interval_1 = Slicer.make_interval(claim_1)
    assert interval_1 == [x1: 2, y1: 4, x2: 5, y2: 7]

    claim_3 = Slicer.make_claim("#3 @ 5,5 2x2")
    interval_3 = Slicer.make_interval(claim_3)
    assert interval_3 == [x1: 6, y1: 6, x2: 7, y2: 7]
    assert Slicer.interval_intersection(interval_1, interval_3) == nil
  end

  test "find union of intersection of three intervals" do
    int_1 = [x1: 2, y1: 4, x2: 5, y2: 7]
    int_2 = [x1: 4, y1: 2, x2: 7, y2: 5]
    int_3 = [x1: 6, y1: 6, x2: 7, y2: 7]

    assert Slicer.make_all_interval_intersections([int_1, int_2, int_3]) == [
             [x1: 4, y1: 4, x2: 5, y2: 5]
           ]
  end

  test "find union of intersection of three other intervals" do
    int_1 = [x1: 1, y1: 1, x2: 2, y2: 2]
    int_2 = [x1: 2, y1: 2, x2: 3, y2: 3]
    int_3 = [x1: 1, y1: 2, x2: 2, y2: 3]

    assert Slicer.make_all_interval_intersections([int_1, int_2, int_3]) ==
             [
               [x1: 2, y1: 2, x2: 2, y2: 3],
               [x1: 2, y1: 2, x2: 2, y2: 2],
               [x1: 1, y1: 2, x2: 2, y2: 2]
             ]
  end

  test "obtain points  from a region" do
    assert Slicer.obtain_points(x1: 2, y1: 2, x2: 2, y2: 3) == [{2, 2}, {2, 3}]
    assert Slicer.obtain_points(x1: 2, y1: 2, x2: 2, y2: 2) == [{2, 2}]
  end

  test "obtain unique points from a list of regions" do
    r1 = [x1: 2, y1: 2, x2: 2, y2: 3]
    r2 = [x1: 2, y1: 2, x2: 2, y2: 2]
    r3 = [x1: 1, y1: 2, x2: 2, y2: 2]
    result = MapSet.new([{1, 2}, {2, 2}, {2, 3}])
    assert Slicer.all_unique_points([r1, r2, r3]) == result
  end

  test "part 1 solution for my file (each person receives its own)" do
    # Result 111935
    assert Slicer.solve_part_1("input") == 111_935
  end

  test "part 2 solution for my file (each person receives its own)" do
    assert Slicer.find_claim_that_doesnt_overlap("input") == 650
  end
end
