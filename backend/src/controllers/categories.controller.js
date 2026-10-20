const categoryModel = require('../models/category.model');
const asyncHandler = require('../utils/asyncHandler');
const { ok } = require('../utils/response');

exports.list = asyncHandler(async (_req, res) => ok(res, await categoryModel.all()));
