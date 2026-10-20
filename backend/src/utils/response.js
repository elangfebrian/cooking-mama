/** Format respons sukses yang konsisten: { success: true, data, meta? } */
exports.ok = (res, data, meta, status = 200) => {
  const body = { success: true, data };
  if (meta) body.meta = meta;
  return res.status(status).json(body);
};
exports.created = (res, data) => exports.ok(res, data, undefined, 201);
