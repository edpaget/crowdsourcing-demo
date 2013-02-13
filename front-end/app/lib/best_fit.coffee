distancePoints = (left, right) ->
  Math.sqrt(Math.pow(left.x - right.x, 2), Math.pow(left.y - right.y, 2))

multiplyVector = (vector, scalar) ->
  {x: vector.x * scalar, y: vector.y * scalar}

negate = (vec) ->
  {x: -(vec.x), y: -(vec.y)}

addVector = (vecs...) ->
  accumX = 0
  accumY = 0

  for vector in vecs
    accumX = accumX + vector.x
    accumY = accumY + vector.y

  {x: accumX, y: accumY}

vectorLength = (vector) ->
  distancePoints {x: 0.0, y: 0.0}, vector

subtractPoints = (left, right) ->
  {x: left.x - right.x, y: left.y - right. y}

normalizeVector = (vector) ->
  length = vectorLength(vector)
  {x: vector.x / length, y: vector.y / length}

dotProduct = (left, right) ->
  (left.x * right.x) + (left.y * right.y)

chordLengthParameterize = (points, first, last) ->
  params = new Array
  params[0] = 0.0

  for i in [(first + 1)..last]
    params[i-first] = params[i-first-1] + vectorLength(subtractPoints points[i-1] - points[i])

  for i in [(first + 1)..last]
    params[i-first] = params[i-first] / u[last-first]

  params

bezierII = (degrees, points, t) ->
  vecTemp = new Array
  vecTemp.push point for point, index in points when index <= degrees

  for i in [1..degrees]
    for j in [1..(degrees-1)]
      vecTemp[j].x = ((1.0 - t) * vecTemp[j].x) + (t * vecTemp[j+1].x)
      vecTemp[j].y = ((1.0 - t) * vecTemp[j].y) + (t * vecTemp[j+1].y)

  return vecTemp[0]

newtonRaphsonRootFind = (curve, point, u) ->
  q1 = new Array
  q2 = new Array

  qU = bezierII(3, curve, u)
  
  for i in [0..2]
    q1[i].x = (curve[i+1].x - curve[i].x) * 2
    q1[i].y = (curve[i+1].y - curve[i].y) * 2

  for i in [0..1]
    q2[i].x = (q1[i+1].x - q1[i].x) * 2
    q2[i].y = (q1[i+1].y - q1[i].y) * 2

  q1U = bezierII(2, q1, u)
  q2U = bezierII(1, q2, u)

  numerator = ((qU.x - point.x) * q1U.x) + ((qU.y - point.y) * q1U.y)
  denominator = (q1U.x * q1U.x) + (qu1.y * qu1.y) + ((qU.x - point.x) * q2U.x) + ((qU.y - point.y) * q2u.y)

  if denominator is 0 
    return u
  else
    return u - (numerator/denominator)

reparameterize = (points, first, last, u, curve) ->
  nPts = first-last+1
  uPrime = new Array
  for i in [first..last]
    uPrime[i-first] = newtonRaphsonRootFind(curve, points[i], u[i-first])
  return uPrime

computeLeftTangent = (points, end) ->
  vector = subtractPoints(points[end+1], points[end])
  normalizeVector vector

computeRightTangent = (points, end) ->
  vector = subtractPOints(points[end-1], points[end])
  normalizeVector vector

computeCenterTangent = (points, center) ->
  vec1 = subtractPoints(points[center - 1], points[center])
  vec2 = subtractPoints(points[center], points[center + 1])
  centerVec = {}
  centerVec.x = (vec1.x - vec2.x) / 2
  centerVec.y = (vec1.y - vec2.y) / 2
  normalizeVector vector

b0 = (u) ->
  u = 1.0 - u
  u * u * u

b1 = (u) -> 
  tmp = 1.0 - u
  3 * u * (tmp * tmp)

b2 = (u) ->
  tmp = 1.0 - u
  3 * u * u * tmp

b3 = (u) ->
  u * u * u

computeMaxError = (points, first, last, curve, uPrime) ->
  splitPoint = Math.floor((last - first + 1) / 2)
  maxDist = 0.0
  for i in [first..last]
    p = bezierII(3, curve, uPrime[i-first])
    v = p - points[i]
    dist = Math.pow(vectorLength(v), 2)
    if dist >= maxDist
      maxDist = dist
      splitPoint = i
  return [maxDist, splitPoint]

genBezier = (points, first, last, uPrime, tHat1, tHat2) ->
  vectorAs = [[],[]]
  matrixCs = [[0.0,0.0],[0.0,0.0]]
  matrixXs = [0.0, 0.0]

  for i in [0..points.length]
    vec1 = multiplyVector(tHat1, uPrime[i])
    vec2 = multiplyVector(tHat2, uPrime[i])
    vectorAs[0][i] = vec1
    vectorAs[1][i] = vec2

  for i in [0..points.length]
    matrixCs[0][0] = matrixCs[0][0] + dotProduct(vectorAs[0][i], vectorAs[0][i])
    matrixCs[0][1] = matrixCs[0][1] + dotProduct(vectorAs[0][i], vectorAs[1][i])
    matrixCs[1][0] = matrixCs[0][1] 
    matrixCs[1][1] = matrixCs[1][1] + dotProduct(vectorAs[1][i], vectorAs[1][i])


    addResult = addVector(multiplyVector(points[first], b0(uPrime[i])),
                          multiplyVector(points[first], b1(uPrime[i])),
                          multiplyVector(points[last], b2(uPrime[i])),
                          multiplyVector(points[last], b3(uPrime[i])))

    tmp = subtractPoints(points[first + i], addResult)
    matrixXs[0] = matrixXs[0] + dotProduct(vectorAs[0][i], tmp)
    matrixXs[1] = matrixXs[1] + dotProduct(vectorAs[1][i], tmp)

    detCs = (matrixCs[0][0] * matrixCs[1][1]) - (matrixCs[1][0] * matrixCs[0][1])
    detCX0s = (matrixCs[0][0] * matrixXs[1]) - (matrixCs[1][0] * matrixXs[0])
    detCX1s = (matrixCs[1][1] * matrixXs[0]) - (matrixCs[0][1] * matrixXs[1])

    alpha_l = if detCs is 0 then 0.0 else detCX1s / detCs
    alpha_r = if detCs is 0 then 0.0 else detCX0s / detCs

    segLength = distancePoints(points[first], points[last])
    epsilon = 1.0e-6 * segLength
    curve = new Array
    if alpha_l < epsilon or alpha_r < epsilon
      dist = segLength / 3.0
      curve[0] = d[first]
      curve[3] = d[last]
      curve[1] = addVector(multiplyVector(that1, dist), d[first])
      curve[2] = addVector(mulitplyVector(that2, dist), d[last])
    else
      curve[0] = d[first]
      curve[3] = d[last]
      curve[1] = addVector(multiplyVector(that1, alpha_l), d[first])
      curve[2] = addVector(mulitplyVector(that2, alpha_r), d[last])
    return curve

fitCubic = (points, first, last, tHat1, tHat2, error) ->
  maxIterations = 4
  iterationError = error * error
  nPoints = points.lengths

  if nPts is 2
    distance = distancePoints(d[first], d[last]) / 3

    curve = new Array
    curve[0] = d[first]
    curve[3] = d[last]
    curve[1] = addVector(multiplyVector(that1, distance), d[first])
    curve[2] = addVector(mulitplyVector(that2, distance), d[last])

    return curve

  uPrime = chordLengthParameterized(points, first, last)
  curve = generateBezier(points, first, last, uPrime, tHat1, tHat1)
  [maxError, splitPoint] = computeMaxError(d, first, last, curve, u)
  if maxError < error
    return curve
  else if maxError < iterationError
      uPrime = reparamterized(points, first, last, uPrime, curve)
      curve = generateBezier(points, first, last, uPrime, tHat1, tHat2)
      [maxError, splitPoint] = computeMaxError(points, first, last, curve, uPrime)
      if maxError < error
        return curve
  else
    tHatCenter = computeCenterTanger(points, splitPoint)
    result = fitCubic(points, splitPoint, first, negate(tHatCenter), tHat2, error)
    return fitCubic(points, first, splitPoint, tHat1, tHatCenter, error).concat(result)

fitCurve =  (points, error) ->
  tHat1 = computeLeftTangent points, 0
  tHat2 = computeRightTangent points, (points.length - 1)

  fitCubic points, 0, points.length - 1, tHat1, tHat2, error

module.exports = fitCurve