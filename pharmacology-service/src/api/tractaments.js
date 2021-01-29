module.exports = (app, options) => {
  const {repo} = options

  app.post('/tractaments', (req, res, next) => {
    repo.getTractaments(req.body).then(_tractaments => {
      res.status(200).json(_tractaments)
    }).catch(next)
  })


}
