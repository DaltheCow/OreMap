CREATE TABLE chips (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  eater_id INTEGER,

  FOREIGN KEY(eater_id) REFERENCES human(id)
);

CREATE TABLE eaters (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  factory_id INTEGER,

  FOREIGN KEY(factory_id) REFERENCES human(id)
);

CREATE TABLE factories (
  id INTEGER PRIMARY KEY,
  address VARCHAR(255) NOT NULL
);

INSERT INTO
  factories (id, address)
VALUES
  (1, "1st and Fattest"), (2, "Where the sidewalk ends");

INSERT INTO
  eaters (id, fname, lname, factory_id)
VALUES
  (1, "Big", "Mouth", 1),
  (2, "Little", "Tummy", 1),
  (3, "About", "ToEat", 2),
  (4, "CouldEat", "ACow", NULL);

INSERT INTO
  chips (id, name, eater_id)
VALUES
  (1, "Little Chip", 1),
  (2, "Big Chip", 2),
  (3, "Monstah Chip", 3),
  (4, "Sunny Chip", 3),
  (5, "Sour Chip", NULL);
