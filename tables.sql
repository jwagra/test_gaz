CREATE TABLE public.message (
	created timestamp(0) NOT NULL,
	id varchar NOT NULL,
	int_id bpchar(16) NOT NULL,
	str varchar NOT NULL,
	status bool NULL,
	CONSTRAINT message_id_pk PRIMARY KEY (id)
);
CREATE INDEX message_created_idx ON public.message USING btree (created);
CREATE INDEX message_int_id_idx ON public.message USING btree (int_id);

CREATE TABLE public.log (
	created timestamp(0) NOT NULL,
	int_id bpchar(16) NOT NULL,
	str varchar NULL,
	address varchar NULL
);
CREATE INDEX log_address_idx ON public.log USING hash (address);