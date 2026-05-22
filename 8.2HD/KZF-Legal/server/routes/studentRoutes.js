const express = require("express");

const router = express.Router();

router.get("/", (req, res) => {
  res.status(200).json({
    name: "Phuc Anh Thu Nguyen",
    studentId: "223212228",
  });
});

module.exports = router;
