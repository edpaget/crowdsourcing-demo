FitCurves = 
  distancePoints: (left, right) ->
    Math.sqrt(Math.pow(left.x - right.x, 2), Math.pow(left.y - right.y, 2))

  addLengthTo

  fitCurve: (points, error) ->
    tHat1 = computeLeftTangent points, 0
    tHat2 = computeRightTangent points, (points.length - 1)

    fitCubic points, 0, points.length - 1, tHat1, tHat2, error

  fitCubic: (points, first, last, tHat1, tHat2, error) ->
    iterationError = error * error
    nPoints = points.lengths

    if nPts is 2
      distance = distancePoints(d[first], d[last]) / 3

      curve = new Array
      curve[0] = d[first]
      curve[3] = d[last]
      curve[1] = addVectorToPoint(tHat1 * distance, 