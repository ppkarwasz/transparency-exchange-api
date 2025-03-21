-- External identifiers like TEI, CPE, PURL, ISBN, EAN...
CREATE TABLE identifier
(
    id    BIGSERIAL,
    type  VARCHAR NOT NULL,
    value VARCHAR NOT NULL
);

-- Author or group
CREATE TABLE author
(
    id        BIGSERIAL,
    parent_id BIGINT REFERENCES author (id),
    name      VARCHAR NOT NULL,
    email     VARCHAR,
    url       VARCHAR,
    flags     BIGINT  NOT NULL -- e.g. for an organisation
);

--
-- Security-related documents a.k.a. artifacts
--
CREATE TABLE document
(
    uuid uuid    NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL
);

-- Author of a document
CREATE TABLE document_author
(
    id            BIGSERIAL NOT NULL PRIMARY KEY,
    document_uuid uuid      NOT NULL UNIQUE REFERENCES document (uuid),
    author_id     BIGINT    NOT NULL REFERENCES author (id)
);

-- Concrete representation of a document
CREATE TABLE document_format
(
    id            uuid        NOT NULL PRIMARY KEY,
    external_id   BIGINT REFERENCES identifier (id), -- For a CycloneDX identifier
    type          VARCHAR     NOT NULL,
    contentType   VARCHAR     NOT NULL,
    size          INTEGER     NOT NULL,
    url           VARCHAR     NOT NULL,
    sha256        VARCHAR(32) NOT NULL,
    signature_url VARCHAR,
    PRIMARY KEY (id)
);

--
-- Versioned set of documents a.k.a. Collection
--
CREATE TABLE collection
(
    id            BIGSERIAL PRIMARY KEY,
    uuid          uuid    NOT NULL,
    version       INTEGER NOT NULL DEFAULT 1,
    update_type   VARCHAR,
    update_reason VARCHAR
);

CREATE TABLE collection_author
(
    id            BIGSERIAL PRIMARY KEY,
    collection_id BIGINT NOT NULL REFERENCES collection (id),
    author_id     BIGINT NOT NULL REFERENCES author (id)
);

CREATE TABLE collection_document
(
    id            BIGSERIAL PRIMARY KEY,
    collection_id BIGINT NOT NULL REFERENCES collection (id),
    document_uuid uuid   NOT NULL REFERENCES document (uuid)
);

--
-- Leaf, a.k.a engineering product
--
CREATE TABLE leaf
(
    uuid uuid    NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL
);

CREATE TABLE leaf_collection
(
    id              BIGSERIAL,
    leaf_uuid       uuid    NOT NULL REFERENCES leaf (uuid),
    version         VARCHAR NOT NULL,
    release_date    DATE    NOT NULL,
    collection_uuid uuid    NOT NULL REFERENCES collection (uuid),
    flags           BIGINT -- For pre-release and stuff
);

--
-- Product, a.k.a. marketing product
--
CREATE TABLE product
(
    uuid uuid    NOT NULL PRIMARY KEY,
    name VARCHAR NOT NULL
);

CREATE TABLE product_leaf
(
    id           BIGSERIAL NOT NULL PRIMARY KEY,
    product_uuid uuid      NOT NULL REFERENCES product (uuid),
    leaf_uuid    uuid      NOT NULL REFERENCES leaf (uuid)
)